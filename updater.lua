local repo = "Flo0205/cc-homecontrol"
local branch = "master"
local commitURL = "https://api.github.com/repos/" .. repo .. "/commits/" .. branch
local apiURL = "https://api.github.com/repos/" .. repo .. "/git/trees/" .. branch .. "?recursive=1"
local baseURL = "https://raw.githubusercontent.com/" .. repo .. "/" .. branch .. "/"
local commitFile = ".lastcommit"  -- Hidden file to store the last commit hash

term.clear()
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

-- Download each file
for _, file in ipairs(files) do
    print("Downloading: " .. file)
    shell.run("wget", baseURL .. file, file)
end

-- Save the latest commit hash
local file = fs.open(commitFile, "w")
file.write(latestCommit)
file.close()

print("Update complete! Now at commit: " .. latestCommit)
