
/*

DROP TABLE ACAO_PROFISSIONAL;
DROP TABLE ACAO_VOLUNTARIA;
DROP TABLE DINHEIRO_ARRECADADO;
DROP TABLE ORGANIZADORES;
DROP TABLE MEMBRO;
DROP TABLE PARTICIPACAO;
DROP TABLE PROMOCAO;
DROP TABLE REMESSA;
DROP TABLE TIPO_VOLUNTARIO;
DROP TABLE VACINAS;
DROP TABLE PRODUTO_DOADO;
DROP TABLE PET;
DROP TABLE EVENTO;
DROP TABLE VOLUNTARIO_AMADOR;
DROP TABLE VOLUNTARIO_PROFISSIONAL;
DROP TABLE VOLUNTARIO;
DROP TABLE PETSHOP;

*/


/*
    Convenção CPF: nnn.nnn.nnn-nn
    Convenção datas: dd/mm/yyyy
    Convenção telefone: (nn) nnnnn-nnnn
    Convenção CEP: nnnnn-nnn
    Convenção CRM: CRM/SP nnnnnn
    Convenção CNPJ: nn.nnn.nnn/nnnn-nn
*/


CREATE TABLE VOLUNTARIO(
    CPF CHAR(14) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    DATA_NASCIMENTO DATE NOT NULL,
    EMAIL VARCHAR2(50) NOT NULL,
    TELEFONE CHAR(15) NOT NULL,
    
    CONSTRAINT PK_VOLUNTARIO PRIMARY KEY (CPF),
    CONSTRAINT SK_VOLUNTARIO UNIQUE (EMAIL),
    CONSTRAINT CK_VOLUNTARIO_CPF CHECK (REGEXP_LIKE(CPF, '[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[0-9]{2}')),
    CONSTRAINT CK_VOLUNTARIO_TEL CHECK (REGEXP_LIKE(TELEFONE, '\([0-9]{2}\) [0-9]{5}-[0-9]{4}'))

);

CREATE TABLE TIPO_VOLUNTARIO (
    VOLUNTARIO CHAR(14) NOT NULL,
    TIPO VARCHAR2(12) NOT NULL,
    
    CONSTRAINT PK_TIPO_VOLUNTARIO PRIMARY KEY (VOLUNTARIO, TIPO),
    CONSTRAINT FK_TIPO_VOLUNTARIO FOREIGN KEY (VOLUNTARIO)
                                  REFERENCES VOLUNTARIO(CPF)
                                  ON DELETE CASCADE,
    CONSTRAINT CK_TIPO_VOLUNTARIO CHECK (UPPER(TIPO) IN ('AMADOR','PROFISSIONAL'))
);


CREATE TABLE VOLUNTARIO_AMADOR(
    VOLUNTARIO CHAR(14) NOT NULL,
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER NOT NULL,
    COMPLEMENTO VARCHAR2(50),
    
    CONSTRAINT PK_VOLUNTARIO_AMADOR PRIMARY KEY (VOLUNTARIO),
    CONSTRAINT FK_VOLUNTARIO_AMADOR FOREIGN KEY (VOLUNTARIO)
                                  REFERENCES VOLUNTARIO(CPF)
                                  ON DELETE CASCADE,
    CONSTRAINT CK_VOLUNTARIO_AMADOR CHECK (REGEXP_LIKE(CEP, '[0-9]{5}-[0-9]{3}'))
);

CREATE TABLE VOLUNTARIO_PROFISSIONAL(
    VOLUNTARIO CHAR(14) NOT NULL,
    CRM CHAR(13) NOT NULL,
    
    CONSTRAINT PK_VOLUNTARIO_PROFISSIONAL PRIMARY KEY (VOLUNTARIO),
    CONSTRAINT FK_VOLUNTARIO_PROFISSIONAL FOREIGN KEY (VOLUNTARIO)
                                  REFERENCES VOLUNTARIO(CPF)
                                  ON DELETE CASCADE,
    CONSTRAINT CK_VOLUNTARIO_PROFISSIONAL CHECK (REGEXP_LIKE(CRM, 'CRM/\w\w [0-9]{6}'))
);

CREATE TABLE ACAO_PROFISSIONAL(
    PROFISSIONAL CHAR(14) NOT NULL,
    DATA DATE NOT NULL,
    DESCRICAO VARCHAR2(50) NOT NULL,
    
    CONSTRAINT PK_ACAO_PROFISSIONAL PRIMARY KEY (PROFISSIONAL, DATA),
    CONSTRAINT FK_ACAO_PROFISSIONAL FOREIGN KEY (PROFISSIONAL)
                                    REFERENCES VOLUNTARIO_PROFISSIONAL(VOLUNTARIO)
                                    ON DELETE CASCADE
);

CREATE TABLE DINHEIRO_ARRECADADO(
    VOLUNTARIO CHAR(14) NOT NULL,
    DATA DATE NOT NULL,
    VALOR NUMBER NOT NULL,
    
    CONSTRAINT PK_DINHEIRO_ARRECADADO PRIMARY KEY (VOLUNTARIO, DATA),
    CONSTRAINT FK_DINHEIRO_ARRECADADO FOREIGN KEY (VOLUNTARIO)
                                      REFERENCES VOLUNTARIO_AMADOR(VOLUNTARIO)
                                      ON DELETE CASCADE
);

CREATE TABLE PRODUTO_DOADO(
    VOLUNTARIO CHAR(14) NOT NULL,
    DATA DATE NOT NULL,
    TIPO VARCHAR2(30) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    QUALIDADE VARCHAR2(10),
    MARCA VARCHAR2(30),
    QUANTIDADE NUMBER NOT NULL,
    PORTE_DESTINO VARCHAR2(7) NOT NULL,
    
    CONSTRAINT PK_PRODUTO_DOADO PRIMARY KEY (VOLUNTARIO, DATA),
    CONSTRAINT FK_PRODUTO_DOADO FOREIGN KEY (VOLUNTARIO)
                                REFERENCES VOLUNTARIO_AMADOR(VOLUNTARIO),
                                --ON DELETE CASCADE, -- ISTO ESTA ERRADO!!!!!!!!!!!!
    CONSTRAINT CK1_PRODUTO_DOADO CHECK (UPPER(QUALIDADE) IN ('OTIMO', 'BOM', 'REGULAR', 'RUIM', 'MUITO RUIM')),
    CONSTRAINT CK2_PRODUTO_DOADO CHECK (UPPER(PORTE_DESTINO) IN ('GRANDE', 'MEDIO', 'PEQUENO'))
);


CREATE TABLE ACAO_VOLUNTARIA(
    VOLUNTARIO CHAR(14) NOT NULL,
    DATA DATE NOT NULL,
    DESCRICAO VARCHAR2(50) NOT NULL,
    
    CONSTRAINT PK_ACAO_VOLUNTARIA PRIMARY KEY (VOLUNTARIO, DATA),
    CONSTRAINT FK_ACAO_VOLUNTARIA FOREIGN KEY (VOLUNTARIO)
                                    REFERENCES VOLUNTARIO_AMADOR(VOLUNTARIO)
                                    ON DELETE CASCADE
);



CREATE TABLE EVENTO (
    DATA DATE NOT NULL,
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER,
    COMPLEMENTO VARCHAR2(50),
    NOME VARCHAR2(30) NOT NULL,
    
    CONSTRAINT PK_EVENTO PRIMARY KEY(DATA, CEP),
    CONSTRAINT CK_EVENTO CHECK (REGEXP_LIKE(CEP, '[0-9]{5}-[0-9]{3}'))
);

CREATE TABLE MEMBRO(
    CPF CHAR(14) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    DATA_NASCIMENTO DATE NOT NULL,
    EMAIL VARCHAR2(30) NOT NULL,
    TELEFONE CHAR(15) NOT NULL,
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER NOT NULL,
    COMPLEMENTO VARCHAR2(50),
    
    CONSTRAINT PK_MEMBRO PRIMARY KEY (CPF),
    CONSTRAINT CK_MEMBRO_CPF CHECK (REGEXP_LIKE(CPF, '[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[0-9]{2}')),
    CONSTRAINT CK_MEMBRO_TEL CHECK (REGEXP_LIKE(TELEFONE, '\([0-9]{2}\) [0-9]{5}-[0-9]{4}')),
    CONSTRAINT CK_MEMBRO_CEP CHECK (REGEXP_LIKE(CEP, '[0-9]{5}-[0-9]{3}'))
);


CREATE TABLE ORGANIZADORES(
    DATA DATE NOT NULL,
    LOCAL CHAR(9) NOT NULL,
    ORGANIZADOR CHAR(14) NOT NULL,
    
    CONSTRAINT PK_ORGANIZADORES PRIMARY KEY (DATA, LOCAL, ORGANIZADOR),
    CONSTRAINT FK1_ORGANIZADORES FOREIGN KEY (ORGANIZADOR)
                                 REFERENCES MEMBRO(CPF)
                                 ON DELETE CASCADE,
    CONSTRAINT FK2_ORGANIZADORES FOREIGN KEY (DATA, LOCAL)
                                 REFERENCES EVENTO (DATA, CEP)
                                 ON DELETE CASCADE
);


CREATE TABLE PARTICIPACAO(
    DATA DATE NOT NULL,
    LOCAL CHAR(9) NOT NULL,
    VOLUNTARIO CHAR(14) NOT NULL,
    
    CONSTRAINT PK_PARTICIPACAO PRIMARY KEY (DATA, LOCAL, VOLUNTARIO),
    CONSTRAINT FK1_PARTICIPACAO FOREIGN KEY (VOLUNTARIO)
                                 REFERENCES VOLUNTARIO(CPF)
                                 ON DELETE CASCADE,
    CONSTRAINT FK2_PARTICIPACAO FOREIGN KEY (DATA, LOCAL)
                                 REFERENCES EVENTO (DATA, CEP)
                                 ON DELETE CASCADE
);


CREATE TABLE PETSHOP(
    CNPJ CHAR(18) NOT NULL,
    NOME VARCHAR2(30) NOT NULL,
    N_PETS NUMBER NOT NULL,
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER NOT NULL,
    COMPLEMENTO VARCHAR2(50),
    
    CONSTRAINT PK_PETSHOP PRIMARY KEY (CNPJ),
    CONSTRAINT CK_PETSHOP_CEP CHECK (REGEXP_LIKE(CEP, '[0-9]{5}-[0-9]{3}')),
    CONSTRAINT CK_PETSHOP_CNPJ CHECK (REGEXP_LIKE(CNPJ, '[0-9]{2}\.[0-9]{3}\.[0-9]{3}/[0-9]{4}-[0-9]{2}'))
);

CREATE TABLE PROMOCAO(
    PETSHOP CHAR(18) NOT NULL,
    DATA DATE NOT NULL,
    LOCAL CHAR(9) NOT NULL,
    
    CONSTRAINT PK_PROMOCAO PRIMARY KEY (DATA, LOCAL, PETSHOP),
    CONSTRAINT FK1_PROMOCAO FOREIGN KEY (PETSHOP)
                                 REFERENCES PETSHOP(CNPJ)
                                 ON DELETE CASCADE,
    CONSTRAINT FK2_PROMOCAO FOREIGN KEY (DATA, LOCAL)
                                 REFERENCES EVENTO (DATA, CEP)
                                 ON DELETE CASCADE
);


CREATE TABLE PET(
    REGISTRO NUMBER NOT NULL,
    ESPECIE VARCHAR2(30),
    GENERO VARCHAR2(30),
    NOME VARCHAR2(30),
    RACA VARCHAR2(30),
    IDADE NUMBER,
    ABRIGO CHAR(18) NOT NULL,
    DATA_ABRIGADO DATE NOT NULL,
    DONO CHAR(14),
    DATA_ADOCAO DATE,
    
    CONSTRAINT PK_PET PRIMARY KEY(REGISTRO),
    CONSTRAINT FK1_PET FOREIGN KEY(ABRIGO)
                       REFERENCES PETSHOP(CNPJ),
                       --ON DELETE CASCADE, -- ISTO ESTA ERRADO!!!!
    CONSTRAINT FK2_PET FOREIGN KEY(DONO)
                       REFERENCES VOLUNTARIO_AMADOR(VOLUNTARIO)
                       ON DELETE SET NULL
);

CREATE TABLE VACINAS(
    PET NUMBER NOT NULL,
    VACINA VARCHAR2(30) NOT NULL,
    
    CONSTRAINT PK_VACINAS PRIMARY KEY (PET, VACINA),
    CONSTRAINT FK_VACINAS FOREIGN KEY(PET)
                          REFERENCES PET(REGISTRO)
                          ON DELETE CASCADE
);


CREATE TABLE REMESSA(
    PETSHOP CHAR(18) NOT NULL,
    VOLUNTARIO CHAR(14) NOT NULL,
    DATA_DOACAO DATE NOT NULL,
    LOTE NUMBER NOT NULL,
    QUANTIDADE NUMBER NOT NULL,
    DATA_REMESSA DATE NOT NULL,
    
    CONSTRAINT PK_REMESSA PRIMARY KEY (PETSHOP, LOTE, VOLUNTARIO, DATA_DOACAO),
    CONSTRAINT FK_REMESSA FOREIGN KEY (VOLUNTARIO, DATA_DOACAO)
                          REFERENCES  PRODUTO_DOADO(VOLUNTARIO, DATA)
                          ON DELETE CASCADE
);





















