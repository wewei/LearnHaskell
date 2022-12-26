module PhoneBook
    ( PhoneBookState
    , new
    , insert
    , lookup
    ) where

import qualified Data.Map as M
import Control.Concurrent ( newMVar, putMVar, takeMVar, MVar )
import Prelude hiding (lookup)

type Name        = String
type PhoneNumber = String
type PhoneBook   = M.Map Name PhoneNumber

newtype PhoneBookState = PhoneBookState (MVar PhoneBook)

new :: IO PhoneBookState
new = do
    m <- newMVar M.empty
    return (PhoneBookState m)

insert :: PhoneBookState -> Name -> PhoneNumber -> IO ()
insert (PhoneBookState m) name number = do
    book <- takeMVar m
    putMVar m $! M.insert name number book -- use strict evaluation to reduce memory consumption

lookup :: PhoneBookState -> Name -> IO (Maybe PhoneNumber)
lookup (PhoneBookState m) name = do
    book <- takeMVar m
    putMVar m book
    return $ M.lookup name book