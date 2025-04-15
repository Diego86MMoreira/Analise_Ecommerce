

Este projeto faz parte do curso [SQL para Análise de Dados](https://www.udemy.com/course/sql-para-analise-de-dados/learn/lecture/30132486#overview).
Em cada curso teremos um estudo de caso com apresentação do cenário, os problemas e os dados para desenvolver projetos em SQL.

## Introdução

Danny adora comida japonesa e, no início de 2021, decidiu abrir um restaurante vendendo seus 3 pratos favoritos: sushi, curry e ramen.

O **Danny's Diner** precisa da sua ajuda para utilizar os dados coletados nos primeiros meses de operação a fim de entender melhor seus clientes e administrar o negócio com mais eficiência.

---

## Problema

Danny quer utilizar os dados disponíveis para responder a perguntas-chave como:

- Quais são os padrões de visita dos clientes?
- Quanto cada cliente gastou no restaurante?
- Quais são os pratos mais pedidos?
- Como está o desempenho do programa de fidelidade?

Com essas informações, Danny pretende:

- Melhorar a experiência dos clientes leais;
- Decidir se deve expandir o programa de fidelidade;
- Criar conjuntos de dados que permitam análises futuras sem uso direto de SQL.

---

## Conjuntos de Dados

A condução da análise foi realizada com PostgreSQL utilizando o PgAdmin.

Os scipts de criação e inserção de dados estão no arquivo [tabelas.sql[(./tabelas.sql).

O estudo utiliza 3 tabelas principais:

### Tabela `sales`

 - **nome_coluna** : descrição

### Tabela `menu`

 - **nome_coluna** : descrição

### Tabela `members`

- **nome_coluna** : descrição


Diagrama ER

![Diagrama de Entidade-Relacionamento](./imagem/diagrama_er.png)

---


## Análises

Os scripts das análises podem ser acessados no arquivo [analise.sql](./analise.sql).


-  Qual é o valor total gasto por cada cliente no restaurante?
>  Foram gastos R$ 1.000,00

```sql
SELECT 
  s.customer_id,
  SUM(m.price) AS total_gasto
FROM 
  sales s
JOIN 
  menu m ON s.product_id = m.product_id
GROUP BY 
  s.customer_id;
```

![Resultado Consulta](./imagem/querie1.png)



## Relatório

Ao analisar os padrões de consumo dos clientes no restaurante, podemos destacar os pontos a seguir.

Despesas e Frequência de Visitas:

-
-
-
-


Esses insights, ao serem considerados de forma integrada, oferecem uma visão abrangente das dinâmicas no restaurante, proporcionando orientação valiosa para estratégias futuras e aprimoramento da experiência do cliente.