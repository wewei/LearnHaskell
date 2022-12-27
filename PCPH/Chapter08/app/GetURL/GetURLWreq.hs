module GetURLWreq (getURL) where

import Data.ByteString ( ByteString )
import Data.ByteString.Lazy (toStrict)
import Network.Wreq ( get, responseBody )
import Control.Lens ( (^.) )

getURL :: String -> IO ByteString
getURL urlStr = toStrict . (^. responseBody) <$> get urlStr
