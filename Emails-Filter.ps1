# Get input file path from user
$inputFile = Read-Host "Enter the path of the input text file containing email list"

# Directory to store results
$resultsDir = "results"

# Create results directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $resultsDir

# Function to process a batch of emails
function Process-Batch($batch) {
    $batch | ForEach-Object {
        $email = $_

        # Extract the ISP domain from the email
        $domain = $email.Split('@')[1]

        # Replace invalid characters in domain to make it a valid filename
        $domainFilename = $domain -replace '[^a-zA-Z0-9]', '_'

        # Create the ISP-specific file if it doesn't exist
        $ispFile = Join-Path -Path $resultsDir -ChildPath "$domainFilename.txt"
        
        # Append batch of emails to the ISP-specific file
        Add-Content -Path $ispFile -Value $email
    }
}

# Set batch size
$batchSize = 1000
$emails = @()

# Read the input file line by line
Get-Content -Path $inputFile | ForEach-Object {
    $email = $_
    $emails += $email

    # Process batch when reaching batch size
    if ($emails.Count -ge $batchSize) {
        Process-Batch $emails
        $emails = @()
    }
}

# Process the last batch if it's not empty
if ($emails.Count -gt 0) {
    Process-Batch $emails
}

Write-Output "Emails sorted into ISP-specific files in the '$resultsDir' directory."
