module Cmdlet.Timeout ( run ) where

import Control.Monad ( forM )
import Text.Printf ( printf )
import Data.Maybe ( isJust )

import Data ( sites )
import TimeDownload ( timeDownload )
import Timeout ( timeout )
import Async ( async, wait )

run :: IO ()
run = do
    let interval = 10 ^ (3::Int) * 1200
    as <- forM sites $ async . timeout interval . timeDownload
    rs <- mapM wait as
    printf "%d/%d succeeded\n" (length (filter isJust rs)) (length rs)