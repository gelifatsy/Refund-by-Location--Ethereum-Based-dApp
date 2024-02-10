import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter/widgets.dart";
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class parentModel extends ChangeNotifier {
  final String _rpcURl = "http://192.168.1.5:7545";
  final String _wsURl = "ws://192.168.1.5:7545/";
  final String _privateKey =
      "ae5b4b8c045ce087ddbb1006f35658e197aaafe1050b5d8350dc47fc25439b97";

  bool isLoading = true;
  List<dynamic> addresses = [];
  // late Client _httpClient;
  late EthereumAddress _contractAddress;
  late String _abiCode;
  late Web3Client _client;
// ignore: unused_field
  late Credentials _credentials;
  late String latitude;
  late String longitude;
  late String maxRadius;
  late String payAmount;
  late String compCount;
  late String reqAmount;
  late List empStatusList;
  late DeployedContract _contract;
  late ContractFunction _getEmployees;
  late ContractFunction _setEmployee;
  late ContractFunction _empContractStatus;

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
    // _abi = await rootBundle.loadString("../assets/abi.json");
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
    // _contract = DeployedContract(ContractAbi.fromJson(_abiCode, "Project"),
    //     EthereumAddress.fromHex(_contractAddress));
    // _readCoordinates = _contract.function("readCoordinates");
    // EthereumAddress.fromHex(_contractAddress));
    _contract = await DeployedContract(
        ContractAbi.fromJson(_abiCode, "RefundContract"), _contractAddress);
    // Extracting the functions, declared in contract.
    _getEmployees = _contract.function("getEmployees");
    _setEmployee = _contract.function("setEmployeeAccount");
    _empContractStatus = _contract.function("empContractStatus");
  }

  getEmployeeContractStatus(List address) async {
    initiateSetup();

    List empStatus = [];

    if (addresses.length != 0) {
      for (int i = 0; i < addresses.length; i++) {
        empStatus.add(await _client.call(
            contract: _contract,
            function: _empContractStatus,
            params: [address[i]]));
      }
      empStatusList = empStatus;
    } else {
      empStatusList = [];
    }
    // latitude = empStatus[0].toString();
    // longitude = empStatus[1].toString();
    // maxRadius = empStatus[2].toString();
    // payAmount = empStatus[3].toString();
    // compCount = empStatus[4].toString();
    // reqAmount = empStatus[5].toString();
  }

  getEmployees() async {
    initiateSetup();
    List employees = await _client
        .call(contract: _contract, function: _getEmployees, params: []);
    addresses = employees[0];

    isLoading = false;
    notifyListeners();
  }

  setEmployee(String _empAddr, int _latitude, int _longitude, int _max_radius,
      int _payAmount, int _reqAmount) async {
    initiateSetup();
    print('set employee called');
    print(EthereumAddress.fromHex(_empAddr));

    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _setEmployee,
            parameters: [
              EthereumAddress.fromHex(_empAddr),
              BigInt.from(_latitude),
              BigInt.from(_longitude),
              BigInt.from(_max_radius),
              BigInt.from(_payAmount),
              BigInt.from(_reqAmount)
            ]));
    getEmployees();
    isLoading = false;
    notifyListeners();
  }

  // getCoordinates() async {
  //   initiateSetup();
  //   List readCoordinates = await _client
  //       .call(contract: _contract, function: _readCoordinates, params: []);
  //   x = readCoordinates[0];
  //   y = readCoordinates[1];

  //   latitude = EncryptionDecryption.decryptAES(x);
  //   longitude = EncryptionDecryption.decryptAES(y);
  //   print("Decrypted");
  //   print(latitude);
  //   print(longitude);
  //   isLoading = false;
  //   notifyListeners();
  // }
}