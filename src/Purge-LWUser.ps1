

## プライベートキーをダウンロードしてフォルダに配置します。
## その他のパラメータは Developer コンソールより値を取得して記載してください

$PrivKeyPath = '.\private_2022012345678.key'
$ClientId = 'gRqxxxxxxxxxxxx'
$ClientSecret = 'Tqexxxxxxxx'
$SvcAccount = 'xxxxx.serviceaccount@yourcompanygroupname'
#$domainId = 12345678

$forceDelete = $false
$RateLimit = 240
## 入出力ファイル を指定します。
$UsersCSV = '.\purgeUsers.csv'
# ファイル フォーマット
# 削除ユーサーは、csv の userid 列に、email, userId (GUID), externalKey:{externalKey} で指定


## 出力ログが不要な場合にはコメントアウトしてください。
$resultLog = '.\PurgeResult.log'       # リクエスト処理結果ログ

$sleep = [int] (0.9 * (60 * 1000) / $RateLimit )

$global:Header = $null
$APIEndPoint = 'https://www.worksapis.com/v1.0/users/'


function  Initialize-Header() {
    Import-Module powershell-jwt

    $rsaPrivateKey = Get-Content $PrivKeyPath -AsByteStream

    $iat = [int](Get-Date -UFormat %s)
    $exp = $iat + 3600

    $payload = @{
        sub = $SvcAccount
        iat = $iat
    }
    
    $jwt = New-JWT -Algorithm 'RS256' -SecretKey $rsaPrivateKey -PayloadClaims $payload -ExpiryTimestamp $exp -Issuer $ClientId
    
    $requestHeader = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
    }

    $requestBody = @{
        assertion     = $jwt
        grant_type    = 'urn:ietf:params:oauth:grant-type:jwt-bearer'
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = 'user'
    }

    $url = 'https://auth.worksmobile.com/oauth2/v2.0/token'
    $response = Invoke-RestMethod -Uri $url -Method POST -Headers $requestHeader -Body $requestBody

    $global:Header = @{
        Authorization  = "Bearer " + $response.access_token
        'Content-Type' = 'application/json'
        Accept         = 'application/json'
    }
}

function Remove-LWUser($UserId) {
    if ([String]::IsNullOrEmpty($global:Header)) {
        Initialize-Header
    }
    else {
        Start-Sleep  -Milliseconds $sleep
    }

    $URLEncodedUserId = [System.Web.HttpUtility]::UrlEncode($UserId)
    if ($forceDelete) {
        $requestPath = "$APIEndPoint$URLEncodedUserId/forcedelete"
    }
    else {
        $requestPath = "$APIEndPoint$URLEncodedUserId"
    }

    $response = Invoke-WebRequest -Method DELETE -Uri $requestPath -Headers $global:Header -SkipHttpErrorCheck

    if (![String]::IsNullOrEmpty($resultLog)) {
        $logmsg = (Get-Date  -Format G) + ",処理番号 $i," + $response.StatusCode + "," + $UserId+ "," + $Response.Content 
        Add-Content $resultLog $logmsg
    }
}

$CSVUsers = Import-Csv -path $UsersCSV  -Delimiter "," -Encoding UTF8
Write-Host "読み込まれたユーザー数: " $CSVUsers.count
$i = 1
foreach ($CSVUser in $CSVUsers) {
    Write-Host ”$i 人目処理開始 : "$CSVUser.userid
    Remove-LWUser $CSVUser.userid
    $i++
}
$global:Header = $null
