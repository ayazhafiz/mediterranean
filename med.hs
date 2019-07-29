import Prelude
import System.Environment
import System.Exit
import System.IO
import qualified Data.Map as Map
import Data.Text as Tx (Text, pack, unpack, take, takeEnd, drop)
import Data.Text.Internal.Search
import Data.List
import Data.Maybe
import Control.Monad

splitchars = " ()[]{};\n"

--getIndexes: returns a list of ints that are the indexes of the delims
--getIndexesHelper
gIH :: String -> Char -> [Int]
gIH text delim = indices (Tx.pack $ (:[]) delim) (Tx.pack text)
getIndexes :: String -> String -> [Int]
getIndexes _ "" = []
getIndexes text delims = gIH text (head delims) ++ getIndexes text (tail delims)

--https://stackoverflow.com/questions/48369242/in-haskell-how-can-i-get-a-substring-of-a-text-between-two-indices
substring :: Int -> Int -> Text -> Text
substring start end text = Tx.take (end - start) (Tx.drop start text)

--splitByIndexes: function that returns a list of stings that are each token
splitByIndexes :: String -> [Int] -> [String]
splitByIndexes _ [] = []
splitByIndexes _ [x] = []
splitByIndexes str lst = Tx.unpack (substring (head lst + 1) (lst !! 1) (Tx.pack str)) : Tx.unpack (substring (lst !! 1) ((lst !! 1) + 1) (Tx.pack str))  : splitByIndexes str (tail lst)

--parseCode: returns a list of strings split by delims, includes delims
parseCode :: String -> [String]
parseCode "" = []
parseCode str = splitByIndexes str ((-1) : sort (getIndexes str splitchars) ++ [length str])

--the dictionary used for translating
itToEngDict = Map.fromList[
  ("auto","auto"),
  ("interrompi", "break"),
  ("caso", "case"),
  ("cara", "char"),
  ("carattere", "char"),
  ("cost", "const"),
  ("constante", "const"),
  ("continua", "continue"),
  ("predefinita", "default"),
  ("fa", "do"),
  ("doppio", "double"),
  ("altro", "else"),
  ("enum", "enum"),
  ("enumerazione", "enum"),
  ("ester", "extern"),
  ("esterno", "extern"),
  ("virgola", "float"),
  ("per", "for"),
  ("vaa", "goto"),
  ("se", "if"),
  ("int", "int"),
  ("intero", "int"),
  ("lungo", "long"),
  ("registro", "register"),
  ("restituisci", "return"),
  ("corto", "short"),
  ("segno", "signed"),
  ("dimensionedi", "sizeof"),
  ("statico", "static"),
  ("strutt", "struct"),
  ("struttura", "struct"),
  ("cambria", "switch"),
  ("tipodef", "typedef"),
  ("tipodefinizione", "union"),
  ("senzasegno", "unsigned"),
  ("vuoto", "void"),
  ("volatile", "volatile"),
  ("mentre", "while")]

--the function that helps do the translation based on the map
translateItToEng :: String -> String
translateItToEng x = if Map.member x itToEngDict
    then itToEngDict Map.! x
	else x

main = do
  args <- getArgs
  when (length args /= 1) $ 
      do 
	    putStrLn "Need a file to compile"
	    exitFailure 
  let filename = head args
  contents <- readFile filename
  let output = concatMap translateItToEng $ parseCode contents
  writeFile (filename ++ ".c") output
  --If you reach this point, exit successfully
  putStrLn ("Successfully compiled " ++ filename ++ "!")
  exitSuccess 
