const HDWalletProvider = require('@truffle/hdwallet-provider');
const Web3 = require('web3');
const { interface, bytecode } = require('./compile');

const provider = new HDWalletProvider(
  'edit despair armed breeze slight police teach fiction bubble cluster play survey',
  'https://sepolia.infura.io/v3/0ff59fe3578f40ce9655b4f93ed24cd0'
);
const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log('Attempting to deploy from account', accounts[0]);

  const result = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: bytecode })
    .send({ gas: '1000000', from: accounts[0] });
  console.log(interface);
  console.log('Contract deployed to', result.options.address);
  provider.engine.stop();
};
deploy();
