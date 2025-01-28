-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS Imobiliaria;
USE Imobiliaria;

-- Desabilitando a verificação de chaves estrangeiras para recriação das tabelas
SET foreign_key_checks = 0;

-- Tabela Imoveis
DROP TABLE IF EXISTS Imoveis;
CREATE TABLE Imoveis (
    id_imovel INT AUTO_INCREMENT PRIMARY KEY,
    endereco VARCHAR(255) NOT NULL,
    valor DECIMAL(10,2) NOT NULL
);

-- Tabela Corretores
DROP TABLE IF EXISTS Corretores;
CREATE TABLE Corretores (
    id_corretor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    comissao DECIMAL(5,2) NOT NULL  -- Percentual de comissão
);

-- Tabela Vendas
DROP TABLE IF EXISTS Vendas;
CREATE TABLE Vendas (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    id_imovel INT NOT NULL,
    id_corretor INT NOT NULL,
    preco_bruto DECIMAL(10,2) NOT NULL,
    data_venda DATE NOT NULL,
    custo_documentacao DECIMAL(10,2) NOT NULL,
    valor_comissao DECIMAL(10,2) NOT NULL, -- Calculado por trigger
    FOREIGN KEY (id_imovel) REFERENCES Imoveis(id_imovel),
    FOREIGN KEY (id_corretor) REFERENCES Corretores(id_corretor)
);

-- Reabilitando a verificação de chaves estrangeiras
SET foreign_key_checks = 1;

-- Criando trigger para calcular a comissão automaticamente
DELIMITER $$

CREATE TRIGGER before_insert_vendas
BEFORE INSERT ON Vendas
FOR EACH ROW
BEGIN
    DECLARE comissao_percentual DECIMAL(5,2);

    -- Buscar a comissão do corretor
    SELECT comissao INTO comissao_percentual 
    FROM Corretores 
    WHERE id_corretor = NEW.id_corretor;

    -- Calcular o valor da comissão
    SET NEW.valor_comissao = (NEW.preco_bruto * comissao_percentual) / 100;
END $$

DELIMITER ;

-- Inserindo dados nas tabelas
-- Inserindo imóveis
INSERT INTO Imoveis (endereco, valor) VALUES
('Rua das Aguas, 124', 300000.00),
('Avenida Central, 456', 500000.00),
('Praça da Paz, 789', 250000.00);

-- Inserindo corretores
INSERT INTO Corretores (nome, comissao) VALUES
('Evellyn santos', 8.0),
('Pedro Silva', 5.0),
('Elizama Gonçalo', 4.0);

-- Inserindo vendas
INSERT INTO Vendas (id_imovel, id_corretor, preco_bruto, data_venda, custo_documentacao) VALUES
(1, 1, 300000.00, '2025-01-11', 3500.00),
(2, 2, 500000.00, '2025-01-17', 4500.00),
(3, 3, 250000.00, '2025-01-25', 3000.00);

-- Consultas
-- Unindo as informações solicitadas em uma única saída
SELECT 
    C.nome AS Corretor,
    GROUP_CONCAT(I.endereco SEPARATOR ', ') AS Imoveis_Vendidos, -- Lista de imóveis vendidos
    SUM(V.valor_comissao) AS Total_Comissao, -- Total de comissão por corretor
    SUM(V.custo_documentacao) AS Total_Custo_Documentacao -- Custo total com documentação
FROM 
    Vendas V
JOIN 
    Corretores C ON V.id_corretor = C.id_corretor
JOIN 
    Imoveis I ON V.id_imovel = I.id_imovel
GROUP BY 
    C.nome;
