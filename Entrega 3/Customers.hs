{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

module Customers where

import Data.Aeson
import GHC.Generics
import qualified Data.ByteString.Lazy as B

data Customer = Customer { 
    customerId :: Int,
    name :: String,
    idCNH :: String,
    programPoints :: Int
} deriving (Generic, Show)

instance ToJSON Customer where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON Customer

menuCustomers :: IO ()
menuCustomers = do
  putStrLn "1 - Cadastrar novo cliente"
  putStrLn "2 - Alterar dados de cliente"
  putStrLn "3 - Excluir clientes"
  putStrLn "4 - Listar clientes"
  putStrLn "0 - voltar"
  putStrLn "Opcao: "
  option <- getLine
  if (read option) == 0 then putStrLn ("Retornando...") else do selectedOptionCustomer (read option)

selectedOptionCustomer :: Int -> IO ()
selectedOptionCustomer opcao
  | opcao == 1 = do addCustomer; menuCustomers
  | opcao == 2 = do readFromJSON; menuCustomers
  | opcao == 3 = do removeCustomer; menuCustomers
  | opcao == 4 = do lista <- readFromJSON; printCustomers lista; menuCustomers
  | otherwise = do readFromJSON; menuCustomers

-- Add Customer

addCustomer :: IO ()
addCustomer = do
  putStrLn "\n\nCadastro de novo cliente"
  putStrLn "\nNome: "
  nameGet <- getLine
  putStrLn "\nNumero da CNH: "
  idCNHGet <- getLine

  lista <- readFromJSON
  let newCustomer = Customer {customerId = generateIndex lista, name = nameGet, idCNH = idCNHGet, programPoints = 0}
  let list = addToList lista newCustomer
  writeToJSON list
  putStrLn $ "\nO cliente " ++ nameGet ++ " foi adicionado com sucesso! \n"

generateIndex :: [Customer] -> Int
generateIndex [] = 0
generateIndex x = do
  let lastCustomer = last x
  (customerId) lastCustomer + 1

addToList :: [Customer] -> Customer -> [Customer]
addToList [] x = [x]
addToList x ve = x ++ [ve]

-- Remove Customer

removeItem :: Int -> [Customer] -> [Customer]
removeItem _ [] = []
removeItem x (y : ys)
  | x == (customerId) y = removeItem x ys
  | otherwise = y : removeItem x ys

removeCustomer :: IO ()
removeCustomer = do
  putStrLn "\n\nRemocao de cliente"
  putStrLn "\nIdentificador do cliente: "
  customerIdToDelete <- getLine
  lista <- readFromJSON
  let listaAtualizada = removeItem (read customerIdToDelete :: Int) lista
  writeToJSON listaAtualizada
  putStrLn $ "\nO cliente com o identificador " ++ customerIdToDelete ++ " foi removido com sucesso! \n"

-- List customers

printCustomers :: [Customer] -> IO ()
printCustomers customers = putStrLn ("\n\nId - CNH - Nome do cliente - Pontos de fidelidade\n\n" ++ (listCustomer customers) ++ "\n")

listCustomer :: [Customer] -> String
listCustomer [] = ""
listCustomer (x : xs) = toStringCustomer x ++ ['\n'] ++ listCustomer xs

-- JSON actions

writeToJSON :: [Customer] -> IO ()
writeToJSON list = do
  B.writeFile "db/customers.json" (encode list)

readFromJSON :: IO [Customer]
readFromJSON = do
  input <- B.readFile "db/customers.json"

  let customers = decode input :: Maybe [Customer]

  case customers of
    Nothing -> return []
    Just customers -> return customers

toStringCustomer :: Customer -> String
toStringCustomer (Customer {customerId = i, idCNH = cnh, name = n, programPoints = pp}) = show i ++ " - " ++ cnh ++ " - " ++ n ++ " - " ++ show pp ++ "pts"
