function Invoke-OpenAISummarize {
    param(
        [string]$apiKey,
        [string]$textToSummarize,
        [int]$maxTokens = 60,
        [string]$engine = 'gpt-3.5-turbo-instruct'
    )
    
    $uri = "https://api.openai.com/v1/engines/$engine/completions"
    $headers = @{
        'Authorization' = "Bearer $apiKey"
        'Content-Type' = 'application/json'
    }

    $body = @{
        prompt = "Summarize the following text: `"$textToSummarize`""
        max_tokens = $maxTokens
        n = 1
    } | ConvertTo-Json


    $parameters = @{
        Method      = 'POST'
        URI         = $uri
        Headers     = $headers
        Body        = $body
        ErrorAction = 'Stop'
    }

    try {
        $response = Invoke-RestMethod @parameters
        return $response.choices[0].text.Trim()
    } catch {
        Write-Error "Failed to invoke OpenAI API: $_"
        return $null
    } # try/catch

} # end function 

# import openai API key
$passwordPath = Join-Path (Split-Path $profile) SecretStore.vault.credential
$password = Import-CliXml -Path $passwordPath 
Unlock-SecretStore -Password $password 
$apikey = get-secret -Name openai -AsPlainText   

$summary = Invoke-OpenAISummarize -apiKey $apikey -textToSummarize @'
PowerShell is a task automation and configuration management program from
Microsoft, consisting of a command-line shell and the associated scripting
language. Initially a Windows component only, known as Windows PowerShell,
it was made open-source and cross-platform on August 18, 2016, with the
introduction of PowerShell Core.[5] The former is built on the .NET Framework,
the latter on .NET (previously .NET Core).
'@
