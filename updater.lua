local repo = "Flo0205/cc-homecontrol"
local branch = "master"
local commitURL = "https://api.github.com/repos/" .. repo .. "/commits/" .. branch
local apiURL = "https://api.github.com/repos/" .. repo .. "/git/trees/" .. branch .. "?recursive=1"
local baseURL = "https://raw.githubusercontent.com/" .. repo .. "/" .. branch .. "/"
local commitFile = ".lastcommit"  -- Hidden file to store the last commit hash
local trackedFilesFile = ".tracked_files"  -- Stores a list of files downloaded

print("Checking for updates...")

-- Fetch latest commit hash
local request = http.get(commitURL)
if not request then
    print("Failed to check latest commit. Ensure HTTP is enabled.")
    return
end

local response = request.readAll()
request.close()

local latestCommit = response:match('"sha":"(.-)"')

if not latestCommit then
    print("Failed to retrieve commit hash.")
    return
end

-- Check if the commit hash is already installed
if fs.exists(commitFile) then
    local file = fs.open(commitFile, "r")
    local savedCommit = file.readAll()
    file.close()

    if savedCommit == latestCommit then
        print("Already up to date! (Commit: " .. latestCommit .. ")")
        return
    end
end

print("New update found! Updating to commit: " .. latestCommit)

-- Fetch file list
local request = http.get(apiURL)
if not request then
    print("Failed to fetch file list.")
    return
end

local response = request.readAll()
request.close()

-- Extract file paths
local files = {}
for file in response:gmatch('"path":"(.-)"') do
    table.insert(files, file)
end

if #files == 0 then
    print("No files found.")
    return
end

print("Downloading " .. #files .. " files...")

local oldFiles = {}
if fs.exists(trackedFilesFile) then
    local file = fs.open(trackedFilesFile, "r")
    for line in file.readLine do
        oldFiles[line] = true
    end
    file.close()
end

-- Track new files
local newTrackedFiles = {}

-- Download each file and delete it first to ensure overwrite
for _, file in ipairs(files) do
    if fs.exists(file) then
        fs.delete(file)  -- Ensure the file is deleted before downloading
    end

    print("Downloading: " .. file)
    shell.run("wget", baseURL .. file, file)

    -- Mark this file as still existing
    newTrackedFiles[file] = true
end

-- Remove files that no longer exist in the repository
for file in pairs(oldFiles) do
    if not newTrackedFiles[file] then
        print("Deleting removed file: " .. file)
        fs.delete(file)
    end
end

-- Save the latest commit hash
local file = fs.open(commitFile, "w")
file.write(latestCommit)
file.close()

-- Save new tracked files
local file = fs.open(trackedFilesFile, "w")
for fileName in pairs(newTrackedFiles) do
    file.writeLine(fileName)
end
file.close()

print("Update complete! Now at commit: " .. latestCommit)
