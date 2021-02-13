import cligen
import strutils, strformat
import nre
import httpclient
import json

let urlRe = re"^(https?:\/\/)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$"

type
  ApiResponse = object
    msg: string
    paste_id: string

proc shorten(url: string) =
  if url.isEmptyOrWhitespace:
    quit("fatal: You must specify a url to shorten.", 1)
  
  if url.match(urlRe).isNone:
    quit(&"fatal: {url} is not a valid url.")

  
  var client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json" })

  let body = %* {
    "is_url": true,
    "content": url
  }

  let res = client.request("https://api.katb.in/api/paste", httpMethod = HttpPost, body = $body)
  if res.code != Http201:
    quit("fatal: the server returned an error", 1)

  let parsedRes = to(parseJson(res.body), ApiResponse)
  echo &"success: shortened url is available at https://katb.in/{parsedRes.paste_id}"
  

proc main =
  dispatchMulti([shorten, help = {
    "url": "The url to shorten"
  }])

main()