module Main (main) where

import PhoneBook ( new, insert, lookup )

main :: IO ()
main = do
    s <- new 
    sequence_ [ insert s ("name" <> show n) (show n) | n <- [(1::Int)..10000]]
    PhoneBook.lookup s "name999" >>= print
    PhoneBook.lookup s "unknown" >>= print