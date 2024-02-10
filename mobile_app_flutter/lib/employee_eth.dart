import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import "package:flutter/widgets.dart";
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class childModel extends ChangeNotifier {
  final String _rpcURl = "http://192.168.1.5:7545";
  final String _wsURl = "ws://192.168.1.5:7545/";
  final String _privateKey =
      "08f0242a6ffa48ca38a3e906f53ef42656d36e168ec88a8ddf030d808a0bc9cc"; //######
      //#########################################################################
  bool isLoading = true;
  // late Client _httpClient;
  late EthereumAddress _contractAddress;
  late String _abiCode;
  late Web3Client _client;
  late EthPrivateKey _credentials;
  late DeployedContract _contract;
  late String x;
  late String y;
  late String latitude;
  late String longitude;
  late List empStatus;
  late String balance;
  late ContractFunction _updateCompCountStatus;
  late ContractFunction _empContractStatus;
  childModel() {
    initiateSetup();
  }
  Future<void> initiateSetup() async {
    // _httpClient = Client();
    // _client = Web3Client(
    //     "https://rinkeby.infura.io/v3/84ee596119e643cdb6e534c7c3674cfa",
    //     _httpClient);
    _client = Web3Client(_rpcURl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsURl).cast<String>();
    });
    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    // _abi = await rootBundle.loadString("../assets/.json");
    // _contractAddress = "0x4943030bce7e49dd13b4dd120c0fef7dde3c18a0";

    // Reading the contract abi
    String abiStringFile =
        await rootBundle.loadString("src/artifacts/RefundContract.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);

    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCredentials() async {
    // _credentials = EthPrivateKey.fromHex(
    //     "d585835f87981557df21fbaf99df4c9d06fd374b6efd121c027e0655cee5b627");
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  Future<void> getDeployedContract() async {
    // Telling Web3dart where our contract is declared.
    // _contract = DeployedContract(ContractAbi.fromJson(_abiCode, "Project"),
    // EthereumAddress.fromHex(_contractAddress));
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "RefundContract"), _contractAddress);
    // Extracting the functions, declared in contract.

    _updateCompCountStatus = _contract.function('updateCompCountStatus');
    _empContractStatus = _contract.function('empContractStatus');
  }

  getBalance(String address) async {
    EtherAmount etherAmount =
        await _client.getBalance(EthereumAddress.fromHex(address));
    balance = '${etherAmount.getValueInUnit(EtherUnit.ether)} Eth';
  }

  getContractStatus(String address) async {
    initiateSetup();

    empStatus = await _client.call(
        contract: _contract,
        function: _empContractStatus,
        params: [EthereumAddress.fromHex(address)]);
    print(empStatus);
  }

  updateCompCountStatus(String latitude, String longitude) async {
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _updateCompCountStatus,
            parameters: [
              BigInt.from(int.parse(latitude)),
              BigInt.from(int.parse(longitude))
            ]));
    print('set employee executed');
    isLoading = false;
    notifyListeners();
  }
}