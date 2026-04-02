# Generate a random identifier for the hostname
$randomId = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
$hostname = "kgcoe-eme-humble-$randomId"

# Create a Docker volume if it does not exist
$volumeName = "eme-humble-volume"
if (-not (docker volume ls -q -f name=^$volumeName$)) {
    Write-Host "Creating Docker volume: $volumeName"
    docker volume create $volumeName | Out-Null
}

# Build the Docker image
Write-Host "Building the Docker image..."
docker build -t kgcoe-eme-humble -f ./DOCKERFILE .

# Start the Docker container with noVNC and desktop environment
Write-Host "Starting the Docker container with noVNC..."
docker run -it --rm -p 6081:6080 -p 5902:5901 -v ${volumeName}:/persistent_data --hostname $hostname --name kgcoe-eme-humble kgcoe-eme-humble
Write-Host "Access the desktop in your browser at http://localhost:6081/"
