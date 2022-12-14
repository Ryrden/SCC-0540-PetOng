
import Database as db
import cx_Oracle
from tabulate import tabulate
from sys import platform
import os
import datetime

if platform == 'linux':
    clear_screen = 'clear'
else:
    clear_screen = 'cls'


class System:

    def __init__(self):
        '''
        Este é o construtor da classe System.
        Ele é responsável por inicializar a conexão com o banco de dados e 
        as demais instâncias de classes.
        '''
        self.__connection = db.Database()
        #self.__volunter = volunter.Voluntario()

    def menu(self):
        '''
        Essa função é responsável por exibir o menu principal do sistema.
        '''
        print('''
        1 - Registrar um novo Voluntário
        2 - Excluir um Voluntário
        3 - Listar Voluntários
        4 - Executar Queries Personalizadas
        5 - Sair
        ''')
        option = int(input('Escolha uma opção: '))
        return option

    def run(self):
        '''
        Essa função é responsável por executar o sistema e a partir
        de uma opção do menu, chamar a função responsável por executar
        '''
        option = self.menu()
        os.system(clear_screen)
        while option != 5:
            if option == 1:
                self.insert_volunter()
            elif option == 2:
                self.delete_volunter()
            elif option == 3:
                self.list_volunters()
            elif option == 4:
                self.custom_query()
            elif option == 5:
                self.__connection.close()
                break
            option = self.menu()
            os.system(clear_screen)
        print('Saindo...')

    # VOLUNTARIO

    def insert_volunter(self):
        '''
        Essa função é responsável por registrar um novo voluntário no banco de dados.
        Este  Voluntário pode ser do tipo 'Amador' ou 'Profissional'.
        '''

        print('Dados do Voluntário:\n')
        nome = input('Nome: ')
        cpf = input('CPF (XXX.XXX.XXX-XX): ')
        dataNascimento = input('Data de Nascimento (dd/mm/yyyy): ')
        telefone = input('Telefone (xx x xxxx-xxxx): ')
        email = input('Email (exemplo@email.com): ')

        try:
            dataNascimento = datetime.datetime.strptime(dataNascimento, '%d/%m/%Y')
        except ValueError:
            print("[-] Data esta com o formato errado")
            return
        print('\n Tipo de voluntário\n')
        tipo = input('Tipo (Amador || Profissional): ')

        SQL_AMADOR = ""
        SQL_PROFISSIONAL = ""

        if (tipo.upper() == 'AMADOR'):
            print("Endereço do Voluntário Amador:\n")
            cep = input('CEP (xxxxx-xxx): ')
            numero = input('Número: ')
            complemento = input('Complemento: ')

            SQL_AMADOR = '''INSERT INTO VOLUNTARIO_AMADOR (VOLUNTARIO, CEP, NUMERO, COMPLEMENTO)
                VALUES (:cpf, :cep, :numero, :complemento)'''
        elif (tipo.upper() == 'PROFISSIONAL'):
            print("CRM do Voluntário Profissional:\n")
            crm = input('CRM ([SiglaEstado] XXXXXX): ')

            SQL_PROFISSIONAL = '''INSERT INTO VOLUNTARIO_PROFISSIONAL (VOLUNTARIO, CRM)
                VALUES (:cpf, :crm)'''
        else:
            print('Tipo inválido')
            return

        print('\nInserindo voluntario...')
        # Tratando SQL Injection
        SQL_VOLUNTARIO = '''INSERT INTO VOLUNTARIO(nome, cpf, data_Nascimento, telefone, email)
            VALUES(: nome, : cpf, : dataNascimento, : telefone, : email)'''
        try:
            responde_voluntario = self.__connection.runQueryWithParams(
            SQL_VOLUNTARIO, [nome, cpf, dataNascimento, telefone, email])
        except cx_Oracle.IntegrityError as e:
            print(f"[-] Error : {e}")
            return

        response_profissional=False
        response_amador=False
        if (responde_voluntario):
            if (SQL_AMADOR != ""):
                response_amador = self.__connection.runQueryWithParams(
                    SQL_AMADOR, [cpf, cep, numero, complemento])
            if (SQL_PROFISSIONAL != ""):
                response_profissional = self.__connection.runQueryWithParams(
                    SQL_PROFISSIONAL, [cpf, crm])

            if (response_amador or response_profissional):
                print('Voluntário inserido com sucesso')

    def delete_volunter(self):
        '''
        Essa função é responsável por excluir um voluntário do banco de dados.
        Para que ela seja executada, é necessário que o usuário informe o CPF do voluntário.
        '''
        print('Qual o CPF do voluntário que deseja excluir?')
        cpf = input('CPF (XXX.XXX.XXX-XX): ')

        SQL = '''DELETE FROM VOLUNTARIO 
                    WHERE CPF = :cpf'''

        print("tem certeza que deseja excluir o voluntário?")
        print("1 - Sim")
        print("2 - Não")
        option = int(input('Escolha uma opção: '))
        if option == 1:
            response = self.__connection.runQueryWithParams(SQL, [cpf])
            if (response):
                print('Voluntário deletado com sucesso')
        elif option == 2:
            print('Operação cancelada')

    def list_volunters(self):
        '''
        Essa função é responsável por listar todos os voluntários do banco de dados.
        '''

        SQL = "SELECT * FROM VOLUNTARIO"
        response = self.__connection.runQuery(SQL)
        rows_data = []
        for row in response:
            data = row[2].strftime("%d/%m/%Y")
            rows_data.append([row[0], row[1], data, row[3], row[4]])
        print(tabulate(rows_data, headers=[
              'CPF', 'Nome', 'Data de Nascimento', 'Email', 'Telefone']))

    def custom_query(self):
        '''
        Essa função é responsável por executar uma query customizada criadas a parte do trabalho.
        '''
        while (True):
            submenu = '''
                1 - Executar Query 1
                2 - Executar Query 2
                3 - Executar Query 3
                4 - Executar Query 4
                5 - Executar Query 5
                6 - Executar Query 6
                7 - Voltar ao menu principal
                '''
            print(submenu)
            option = int(input('Escolha uma opção: '))
            os.system(clear_screen)
            if (option == 1):
                SQL = '''	SELECT  v.nome AS DONO, 
        		pet.nome AS PET_NOME, 
        		v.cpf AS CPF, 
        		av.data AS DATA, 
        		av.descricao AS DESCRICAO,
        		SUM(din.valor) AS DINHEIRO_DOADO
		        FROM ACAO_VOLUNTARIA av
		        INNER JOIN VOLUNTARIO v ON v.cpf = av.voluntario
		        INNER JOIN PET pet ON pet.dono = v.cpf
		        INNER JOIN DINHEIRO_ARRECADADO din ON din.voluntario = v.cpf
		        LEFT OUTER JOIN PRODUTO_DOADO prod ON prod.voluntario = v.cpf
		        WHERE prod.nome IS NULL
		        GROUP BY v.nome, pet.nome, v.cpf, av.data, av.descricao
		        HAVING SUM(din.valor) > 500
                 '''
                tab_form = ['Dono', 'Nome_Pet', 'CPF',
                            'Data', 'Descricao', 'Dinheiro doado']

            elif (option == 2):
                SQL = '''
		SELECT  aprof.profissional AS CPF,
        		prof.nome AS NOME,
        		prof.email AS EMAIL,
        		COALESCE(d.dinheiro_doado, 0) AS DINHEIRO_DOADO,
        		COALESCE(p.qnt_doada, 0) AS PRODUTOS_DOADOS,
        		COUNT(aprof.profissional) AS N_ACOES
		FROM ACAO_PROFISSIONAL aprof
		LEFT JOIN (
			    SELECT din.voluntario AS CPF, SUM(din.valor) AS dinheiro_doado FROM DINHEIRO_ARRECADADO din GROUP BY din.voluntario
		) d ON d.cpf = aprof.profissional
		LEFT JOIN (
    				SELECT prod.voluntario AS CPF, SUM(prod.quantidade) AS qnt_doada FROM PRODUTO_DOADO prod GROUP BY prod.voluntario
		) p ON p.cpf = aprof.profissional
		INNER JOIN VOLUNTARIO prof ON prof.cpf = aprof.profissional
		GROUP BY aprof.profissional, prof.nome, prof.email, d.dinheiro_doado, p.qnt_doada
		HAVING COUNT(aprof.profissional) >= 2 
		AND (d.dinheiro_doado >= 300 OR p.qnt_doada > 3)                        '''
                tab_form = ['CPF', 'Nome_Pro', 'Email',
                            'Dinheiro doado', 'Produtos doados', 'Nro de Ações']

            elif (option == 3):
                SQL = '''
			SELECT  prof.voluntario         AS CPF,
        vo.nome                 AS NOME,
        vo.data_nascimento      AS DATA_NASCIMENTO,
        vo.email                AS EMAIL,
        SUM(prod.quantidade)    AS QNT_PRODUTOS
FROM VOLUNTARIO_PROFISSIONAL prof
INNER JOIN ACAO_PROFISSIONAL aprof ON aprof.profissional = prof.voluntario
INNER JOIN PET pet ON pet.dono = prof.voluntario
INNER JOIN PRODUTO_DOADO prod ON prod.voluntario = prof.voluntario
LEFT OUTER JOIN DINHEIRO_ARRECADADO din ON din.voluntario = prof.voluntario
INNER JOIN VOLUNTARIO vo ON vo.cpf = prof.voluntario
WHERE aprof.descricao = 'Castração' AND din.valor IS NULL
GROUP BY prof.voluntario, vo.nome, vo.data_nascimento, vo.email, aprof.descricao
HAVING SUM(prod.quantidade) > 5
ORDER BY QNT_PRODUTOS ASC
                        '''
                tab_form = ['CPF', 'Nome Voluntário',
                            'Nascimento', 'Email', 'Qtd Produtos']

            elif (option == 4):
                SQL = '''
SELECT  petshop.cnpj    AS CNPJ,
        petshop.nome    AS NOME,
        reme.petshop    AS PETSHOP,
        COALESCE(promoc.part, 0) AS NUMERO_PARTICIAPACAO,
        SUM(prod.quantidade) AS QNT_PROD_RECEBIDO
        
FROM PETSHOP petshop
INNER JOIN REMESSA reme ON reme.petshop = petshop.cnpj
INNER JOIN PRODUTO_DOADO prod ON prod.voluntario = reme.voluntario AND prod.data = reme.data_doacao
LEFT JOIN (
    SELECT promocao.petshop AS cnpj, COUNT(promocao.petshop) AS part FROM PROMOCAO GROUP BY promocao.petshop
) promoc ON promoc.cnpj = petshop.cnpj
GROUP BY petshop.cnpj, petshop.nome, reme.petshop, promoc.part
ORDER BY QNT_PROD_RECEBIDO DESC                        '''
                tab_form = ['CNPJ', 'PetShop', 'Remessa',
                            'Participação', 'Qtd Produtos Recebidos']

            elif (option == 5):
                SQL = '''
SELECT  petshop.cnpj    AS CNPJ,
        petshop.nome    AS NOME,
        petshop.n_pets  AS N_MAX_DE_PETS,
        COALESCE(info.ocup,0)       AS N_DE_PETS,
        COALESCE((info.ocup/petshop.n_pets)*100,0) AS PORCENTAGEM_OCUPACAO,
        COUNT(promo.petshop)                        AS PARTICIPACAO_PROMO
FROM PETSHOP petshop
LEFT JOIN PROMOCAO promo ON promo.petshop = petshop.cnpj
LEFT JOIN (
    SELECT pet.abrigo AS cnpj, count(pet.abrigo) AS ocup FROM PET pet WHERE pet.dono IS NULL GROUP BY pet.abrigo
) info ON info.cnpj = petshop.cnpj
GROUP BY petshop.cnpj, petshop.nome, petshop.n_pets, COALESCE(info.ocup,0), COALESCE((info.ocup/petshop.n_pets)*100,0)
HAVING COUNT(promo.petshop) >= 1
ORDER BY PORCENTAGEM_OCUPACAO DESC                        '''
                tab_form = ['CNPJ', 'PetShop', 'Nro max Pets',
                            'Pets', '% Ocupada', 'Participação']

            elif (option == 6):
                SQL = '''
SELECT  petshop.cnpj    AS CNPJ,
        petshop.nome    AS NOME,
        petshop.n_pets  AS N_MAX_DE_PETS,
        COALESCE(info.ocup,0)       AS N_DE_PETS,
        COALESCE((info.ocup/petshop.n_pets)*100,0) AS PORCENTAGEM_OCUPACAO,
        COUNT(promo.petshop)                        AS PARTICIPACAO_PROMO
FROM PETSHOP petshop
LEFT JOIN PROMOCAO promo ON promo.petshop = petshop.cnpj
LEFT JOIN (
    SELECT pet.abrigo AS cnpj, count(pet.abrigo) AS ocup FROM PET pet WHERE pet.dono IS NULL GROUP BY pet.abrigo
) info ON info.cnpj = petshop.cnpj
GROUP BY petshop.cnpj, petshop.nome, petshop.n_pets, COALESCE(info.ocup,0), COALESCE((info.ocup/petshop.n_pets)*100,0)
HAVING COUNT(promo.petshop) >= 1
ORDER BY PORCENTAGEM_OCUPACAO DESC                        '''
                tab_form = ['Reg Pet', 'Nome', 'Raça', 'Petshop', 'Dono']

            elif (option >= 7):
                break

            response = self.__connection.runQuery(SQL)
            rows_data = []
            for i, row in enumerate(response):
                rows_data.append([])
                for e in row:
                    rows_data[i].append(e)
            print(tabulate(rows_data, headers=tab_form))
        print("[+] Voltando ao menu principal")
