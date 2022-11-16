-- ORACLE SQL

/* Observações de implmentação + dúvidas

    1) Com relação aos tipos para dados basicos (CEP, NUMERO, TELEFONE, etc), qual seria a quantidade ideal
    de caracteres para cada um? (ex: CEP = 8, NUMERO = 5, TELEFONE = 11) e o seus tipos (VARCHAR, NUMBER)

    2) CHECK em duas tabelas para garantir consistência ou apenas uma? (ocorre no caso Voluntario e Tipo Voluntario)

    3) Constraint da Unique key, qual a boa prática?? SK, TK, FK, ou UK1, UK2, UK3, etc?

    4) Regex para validar uma data é uma boa ideia?

    5) para CPF e CNPJ está sendo usado char e uma regex de validação, mas n estou considerando os pontos e traços, o SGBD pode formatar o numreo?
*/

/* CONVEÇÕES ADOTADAS

    CPF: XXX.XXX.XXX-XX
    CNPJ: XX.XXX.XXX/XXXX-XX
    CRM: XXX/XX XXXXXX  -- Está certo??

    DATA: DD/MM/AAAA
    CEP: XXXXX-XXX

    TELEFONE: (XX) XXXXX-XXXX
    EMAIL: foo.bar@gmail.com || alguem@orgao.uf.gov.br || etc
*/


CREATE TABLE VOLUNTARIO (
    CPF CHAR(11) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    DATA_NASCIMENTO DATE NOT NULL,
    EMAIL VARCHAR2(50) NOT NULL,
    TELEFONE CHAR(11) NOT NULL,
    TIPO VARCHAR2(12) NOT NULL,

    CONSTRAINT PK_VOLUNTARIO PRIMARY KEY (CPF),
    CONSTRAINT SK_VOLUNTARIO UNIQUE (EMAIL, TELEFONE),
    CONSTRAINT CHECK_VOLUNTARIO_CPF CHECK REGEXP_LIKE(CPF, '[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}'),
    CONSTRAINT CHECK_VOLUNTARIO_DATA_NASCIMENTO 
        CHECK DATA_NASCIMENTO < SYSDATE AND REGEXP_LIKE(DATA_NASCIMENTO, '[0-9]{2}/[0-9]{2}/[0-9]{4}'), --faz sentido checar data?
    CONSTRAINT CHECK_VOLUNTARIO_TEL CHECK REGEXP_LIKE(TELEFONE, '\([0-9]{2}\) [0-9]{5}-[0-9]{4}'),
    CONSTRAINT CHECK_VOLUNTARIO_EMAIL CHECK REGEXP_LIKE(EMAIL, '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}'),
    CONSTRAINT CHECK_VOLUNTARIO_TIPO CHECK (UPPER(TIPO) IN ('AMADOR', 'PROFISSIONAL')),
)

CREATE TABLE TIPO_VOLUNTARIO (
    VOLUNTARIO CHAR(11) NOT NULL,
    TIPO VARCHAR2(12) NOT NULL,

    CONSTRAINT PK_TIPO_VOLUNTARIO PRIMARY KEY (VOLUNTARIO, TIPO),
    CONSTRAINT FK_TIPO_VOLUNTARIO FOREIGN KEY (VOLUNTARIO) 
        REFERENCES VOLUNTARIO(CPF) ON DELETE CASCADE,
    CONSTRAINT CHECK_TIPO_VOLUNTARIO CHECK (UPPER(TIPO) IN ('AMADOR', 'PROFISSIONAL')), -- Verificar se é necessário
)

CREATE TABLE VOLUNTARIO_AMADOR (
    VOLUNTARIO CHAR(11) NOT NULL, --seguindo a modelagem, chamamos de voluntário, mas deveriamos seguir a consistencia de nomes?
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER NOT NULL,
    COMPLEMENTO VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_VOLUNTARIO_AMADOR PRIMARY KEY (CPF),
    CONSTRAINT FK_VOLUNTARIO_AMADOR FOREIGN KEY (CPF) 
        REFERENCES VOLUNTARIO(CPF) ON DELETE CASCADE,
    CONSTRAINT CHECK_VOLUNTARIO_AMADOR_CEP CHECK REGEXP_LIKE(CEP, '[0-9]{5}-[0-9]{3}'),
)

CREATE TABLE VOLUNTARIO_PROFISSIONAL (
    VOLUNTARIO CHAR(11) NOT NULL,
    CRM VARCHAR2(10) NOT NULL,

    CONSTRAINT PK_VOLUNTARIO_PROFISSIONAL PRIMARY KEY (VOLUNTARIO)
    CONSTRAINT SK_VOLUNTARIO_PROFISSIONAL UNIQUE (CRM),
    CONSTRAINT FK_VOLUNTARIO_PROFISSIONAL FOREIGN KEY (VOLUNTARIO) 
        REFERENCES VOLUNTARIO(CPF) ON DELETE CASCADE,
    CONSTRAINT CHECK_VOLUNTARIO_PROFISSIONAL CHECK REGEXP_LIKE(CRM, '[0-9]{3}/[0-9]{2} [0-9]{6}'),
)

CREATE TABLE ACAO_PROFISSIONAL (
    VOLUNTARIO CHAR(11) NOT NULL, --dei o nome de voluntario p/ garantir consistência (poderia ser profissional)
    DATA DATE NOT NULL,
    DESCRICAO VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_ACAO_PROFISSIONAL PRIMARY KEY (VOLUNTARIO, DATA),
    CONSTRAINT FK_ACAO_PROFISSIONAL FOREIGN KEY (VOLUNTARIO) 
        REFERENCES VOLUNTARIO_PROFISSIONAL(CPF) ON DELETE CASCADE, --Referenciar Voluntario profissional ou voluntario?
)

CREATE TABLE ACAO_VOLUNTARIA ( --Acao amadora?
    VOLUNTARIO CHAR(11) NOT NULL,
    DATA DATE NOT NULL,
    DESCRICAO VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_ACAO_VOLUNTARIA PRIMARY KEY (VOLUNTARIO, DATA),
    CONSTRAINT FK_ACAO_VOLUNTARIA FOREIGN KEY (VOLUNTARIO) 
        REFERENCES VOLUNTARIO_AMADOR(CPF) ON DELETE CASCADE,
)

CREATE TABLE DINHEIRO_ARRECADADO (
    VOLUNTARIO CHAR(11) NOT NULL,
    DATA DATE NOT NULL,
    VALOR NUMBER NOT NULL,

    CONSTRAINT PK_DINHEIRO_ARRECADADO PRIMARY KEY (VOLUNTARIO, DATA),
    CONSTRAINT FK_DINHEIRO_ARRECADADO FOREIGN KEY (VOLUNTARIO)
        REFERENCES VOLUNTARIO_AMADOR(CPF) ON DELETE CASCADE,
    CONSTRAINT CHECK_DINHEIRO_ARRECADADO_VALOR CHECK (VALOR > 0),
)

CREATE TABLE PRODUTO_DOADO (
    VOLUNTARIO CHAR(11) NOT NULL,
    DATA DATE NOT NULL,
    TIPO VARCHAR2(50) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    QUALIDADE VARCHAR2(50),
    QUANTIDADE NUMBER NOT NULL,
    MARCA VARCHAR2(50),
    PORTE_DESTINO VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_PRODUTO_DOADO PRIMARY KEY (VOLUNTARIO, DATA),
    CONSTRAINT FK_PRODUTO_DOADO FOREIGN KEY (VOLUNTARIO)
        REFERENCES VOLUNTARIO_AMADOR(CPF) ON DELETE CASCADE,
    CONSTRAINT CHECK_PRODUTO_DOADO_QUANTIDADE CHECK (QUANTIDADE > 0),
)

CREATE TABLE EVENTO (
    NOME VARCHAR2(50) NOT NULL,
    DATA DATE NOT NULL,
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER NOT NULL,
    COMPLEMENTO VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_EVENTO PRIMARY KEY (DATA, CEP),
    CONSTRAINT CHECK_EVENTO_CEP CHECK REGEXP_LIKE(CEP, '[0-9]{5}-[0-9]{3}'),
)

--O membro é quase um voluntario...
CREATE TABLE MEMBRO (
    CPF CHAR(11) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    DATA_NASCIMENTO DATE NOT NULL,
    EMAIL VARCHAR2(50) NOT NULL,
    TELEFONE CHAR(11) NOT NULL,
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER NOT NULL,
    COMPLEMENTO VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_MEMBRO PRIMARY KEY (CPF),
    CONSTRAINT CHECK_MEMBRO_CPF CHECK REGEXP_LIKE(CPF, '[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}'),
    CONSTRAINT CHECK_MEMBRO_DATA_NASCIMENTO 
        CHECK DATA_NASCIMENTO < SYSDATE AND REGEXP_LIKE(DATA_NASCIMENTO, '[0-9]{2}/[0-9]{2}/[0-9]{4}'),
    CONSTRAINT CHECK_MEMBRO_TEL CHECK REGEXP_LIKE(TELEFONE, '\([0-9]{2}\) [0-9]{5}-[0-9]{4}'),
    CONSTRAINT CHECK_MEMBRO_EMAIL CHECK REGEXP_LIKE(EMAIL, '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}'),
    CONSTRAINT CHECK_MEMBRO_CEP CHECK REGEXP_LIKE(CEP, '[0-9]{5}-[0-9]{3}'),
)

-- TABELA N:N
CREATE TABLE EVENTO_ORGANIZADO (
    DATA DATE NOT NULL,
    LOCAL CHAR(9) NOT NULL,
    MEMBRO CHAR(11) NOT NULL, --esse cara é um organizador

    CONSTRAINT PK_EVENTO_ORGANIZADO PRIMARY KEY (DATA, LOCAL, MEMBRO),
    CONSTRAINT FK_EVENTO_ORGANIZADO_EVENTO FOREIGN KEY (DATA, LOCAL) 
        REFERENCES EVENTO(DATA, CEP) ON DELETE CASCADE,
    CONSTRAINT FK_EVENTO_ORGANIZADO_MEMBRO FOREIGN KEY (MEMBRO) 
        REFERENCES MEMBRO(CPF) ON DELETE CASCADE,
)

-- TABELA N:N
CREATE TABLE PARTICIPACAO (
    DATA DATE NOT NULL,
    LOCAL CHAR(9) NOT NULL,
    VOLUNTARIO CHAR(11) NOT NULL, --esse cara é um participante

    CONSTRAINT PK_PARTICIPACAO PRIMARY KEY (DATA, LOCAL, VOLUNTARIO),
    CONSTRAINT FK_PARTICIPACAO_EVENTO FOREIGN KEY (DATA, LOCAL) 
        REFERENCES EVENTO(DATA, CEP) ON DELETE CASCADE,
    CONSTRAINT FK_PARTICIPACAO_VOLUNTARIO FOREIGN KEY (VOLUNTARIO)
)

CREATE TABLE PETSHOP (
    CNPJ CHAR(14) NOT NULL,
    NOME VARCHAR2(50) NOT NULL,
    NRO_PETS NUMBER NOT NULL,
    CEP CHAR(9) NOT NULL,
    NUMERO NUMBER, -- ta certo isso ser not null?
    COMPLEMENTO VARCHAR2(50),

    CONSTRAINT PK_PETSHOP PRIMARY KEY (CNPJ),
    CONSTRAINT CHECK_PETSHOP_CNPJ CHECK REGEXP_LIKE(CNPJ, '[0-9]{2}\.[0-9]{3}\.[0-9]{3}/[0-9]{4}-[0-9]{2}'),
    CONSTRAINT CHECK_PETSHOP_CEP CHECK REGEXP_LIKE(CEP, '[0-9]{5}-[0-9]{3}'),
    CONSTRAINT CHECK_PETSHOP_NRO_PETS CHECK (NRO_PETS > 0),
)

-- TABELA N:N
CREATE TABLE PROMOCAO (
    PETSHOP CHAR(14) NOT NULL,
    DATA DATE NOT NULL,
    LOCAL CHAR(9) NOT NULL,

    CONSTRAINT PK_PROMOCAO PRIMARY KEY (PETSHOP, DATA, LOCAL),
    CONSTRAINT FK_PROMOCAO_PETSHOP FOREIGN KEY (PETSHOP)
        REFERENCES PETSHOP(CNPJ) ON DELETE CASCADE,
    CONSTRAINT FK_PROMOCAO_EVENTO FOREIGN KEY (DATA, LOCAL)
)

CREATE TABLE PET (
    REGISTRO NUMBER NOT NULL,
    ESPECIE VARCHAR2(30),
    GENERO CHAR(5),
    NOME VARCHAR2(30),
    RACA VARCHAR2(30),
    IDADE NUMBER,
    ABRIGO CHAR(18) NOT NULL,
    DATA_ABRIGADO DATE NOT NULL,
    DONO CHAR(14),
    DATA_ADOCAO DATE,

    CONSTRAINT PK_PET PRIMARY KEY (REGISTRO),
    CONSTRAINT FK_PET_PETSHOP FOREIGN KEY (ABRIGO)
        REFERENCES PETSHOP(CNPJ), -- ON DELETE RESTRICT (ñ existe no oracle)
    CONSTRAINT FK_PET_VOLUNTARIO_AMADOR FOREIGN KEY (DONO)
        REFERENCES VOLUNTARIO_AMADOR(CPF) ON DELETE SET NULL,
    CONSTRAINT CHECK_PET_ESPECIE CHECK (UPPER(ESPECIE) IN ('CACHORRO', 'GATO', 'OUTRO')),
    CONSTRAINT CHECK_PET_GENERO CHECK (UPPER(GENERO) IN ('MACHO', 'FEMEA')),
    CONSTRAINT CHECK_PET_DATA_ABRIGADO CHECK (DATA_ABRIGADO < SYSDATE),
    CONSTRAINT CHECK_PET_DATA_ADOCAO CHECK (DATA_ADOCAO < SYSDATE),
    CONSTRAINT CHECK_PET_IDADE CHECK (IDADE > 0),
)

CREATE TABLE VACINAS (
    PET NUMBER NOT NULL,
    NOME VARCHAR2(30) NOT NULL,

    CONSTRAINT PK_VACINAS PRIMARY KEY (PET, NOME),
    CONSTRAINT FK_VACINAS FOREIGN KEY (PET)
        REFERENCES PET(REGISTRO) ON DELETE CASCADE,
)

CREATE TABLE REMESSA (
    PETSHOP CHAR(14) NOT NULL,
    VOLUNTARIO CHAR(11) NOT NULL,
    DATA_DOACAO DATE NOT NULL,
    LOTE NUMBER NOT NULL,
    QUANTIDADE NUMBER NOT NULL,
    DATA_REMESSA DATE NOT NULL,


    CONSTRAINT PK_REMESSA PRIMARY KEY (PETSHOP, VOLUNTARIO, DATA_DOACAO, LOTE),
    CONSTRAINT FK_REMESSA_PETSHOP FOREIGN KEY (PETSHOP)
        REFERENCES PETSHOP(CNPJ),
    CONSTRAINT FK_REMESSA_PRODUTO_DOADO FOREIGN KEY (VOLUNTARIO, DATA_DOACAO, LOTE)
        REFERENCES PRODUTO_DOADO(VOLUNTARIO, DATA),
    -- ON DELETE CASCADE Ñ FAZ SENTIDO AQUI
)