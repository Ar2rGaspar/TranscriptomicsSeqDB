# TranscriptomicsSeqDB
Modelo de teste do TranscriptomicsSeqDB (desatualizado, essa versão é de 02/2024)
<br>
https://ar2rgaspar.github.io/TranscriptomicsSeqDB/

<hr>

<p>- Instalar MariaDB, configurar senha para o root<br>
- Instalar XAMPP para hospedar SQL em uma porta fixa<br>
- Abrir um CMD no diretório do arquivo .sql a ser importado<br>
- Usar "mysql -u root -p" e inserir a senha do root<br>
- Usar "CREATE DATABASE nome_da_database;" após entrar na conta do root<br>
- Usar "USE nome_da_database" para entrar no banco de dados recém-criado<br>
- Usar "source nome_do_arquivo.sql;" para importar os dados em SQL para o recém-criado banco de dados. É possível fazer isso intuitivamente pelo endereço localhost/phpmyadmin/<br>
- Se houver um erro no XAMPP na hora de acessar o phpmyadmin, abrir o arquivo config.inc.php (do diretório do XAMPP) e colocar a senha do root no campo que pede a senha.<br>
<br>
- Instalar o node.JS e as libraries "express", "mysql" e "cors" através dos comandos "npm install nome_da_library"<br>
- Para ligar o Node.JS, abrir um CMD no diretório do website e inserir "node server.js run"<br>
- Para ligar o servidor do Limma, abrir um CMD do R, colocar no diretório do app.R a partir de setwd("C:/Diretório") e usar shiny::runApp(port = 3865)</p>
