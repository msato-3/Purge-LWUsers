# Purge-LWUsers

先日、LINE WORKS の[ユーザーの一括追加スクリプト](https://github.com/msato-3/Import-LWUsers) を書いてみましたが、今度はユーザーの一括削除スクリプトを書いてみました。

[1.1. アプリの作成](https://github.com/msato-3/Import-LWUsers/edit/msato-3-patch-1/README.md#11-%E3%82%A2%E3%83%97%E3%83%AA%E3%81%AE%E4%BD%9C%E6%88%90) と [2. PowerShellの準備](https://github.com/msato-3/Import-LWUsers/edit/msato-3-patch-1/README.md#%EF%BC%92-powershell-%E3%81%AE%E6%BA%96%E5%82%99) はリンク先を参照してください。
以下に、[ユーザーの一括追加スクリプト(Import-LWUsers)] との違いのみ記載します。


 ## スクリプトの変更
 今回のスクリプトでは `$domainId` は使用しませんので、記載の必要はありません。  
 ログファイルは、以下のフィアルのみです。
 ```
 $resultLog = '.\PurgeResult.log'       # リクエスト処理結果ログ
 ```
 
 
 LINE WORKS のユーザー削除には、通常の削除と、即時削除の 2 種類があります。このスクリプトは、既定では通常の削除を行います。即時削除を行いたい場合には、
 ```
 $forceDelete = $false
 ```
 を
 ```
 $forceDelete = $true
 ```
 に変更してください。
 
  ## 削除ユーザーの指定
 削除対象のユーザーは、`PurgeUsers.csv` に記載します。`email`、`userId`、`externalKey:{externalKey}` の形式で指定できます。
 
 
