// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Marketplace {
    struct Produto {
        uint256 id;
        string nome;
        uint256 preco;
        address vendedor;
        address comprador;
        bool comprado;
    }

    mapping(uint256 => Produto) public produtos;

    uint256 public quantidadeDeProdutos;

    event ProdutoCriado(
        uint256 id,
        string nome,
        uint256 preco,
        address vendedor,
        bool comprado
    );

    event ProdutoComprado(
        uint256 id,
        string nome,
        uint256 preco,
        address vendedor,
        address comprador,
        bool comprado
    );

    function criarProduto(string memory _nome, uint256 _preco) public {
        require(bytes(_nome).length > 0, "O nome do produto nao pode estar vazio");
        require(_preco > 0, "O preco do produto deve ser maior que zero");

        quantidadeDeProdutos++;

        produtos[quantidadeDeProdutos] = Produto(
            quantidadeDeProdutos,
            _nome,
            _preco,
            msg.sender,
            address(0),
            false
        );

        emit ProdutoCriado(quantidadeDeProdutos, _nome, _preco, msg.sender, false);
    }

    function comprarProduto(uint256 _id) public payable {
        Produto memory _produto = produtos[_id];

        require(_produto.id > 0 && _produto.id <= quantidadeDeProdutos, "ID de produto invalido");
        require(!_produto.comprado, "Produto ja foi comprado");
        require(msg.sender != _produto.vendedor, "O vendedor nao pode comprar o proprio produto");
        require(msg.value == _produto.preco, "Quantidade de pagamento incorreta");

        _produto.comprador = msg.sender;
        _produto.comprado = true;
        produtos[_id] = _produto;

        payable(_produto.vendedor).transfer(msg.value);

        emit ProdutoComprado(
            _id,
            _produto.nome,
            _produto.preco,
            _produto.vendedor,
            _produto.comprador,
            true
        );
    }
}

