var app = angular.module('app', []); 

//Configure preferences for the Angular app

app.config(function($locationProvider){
	$locationProvider.html5Mode({
		enabled:true,
		requireBase: false
	});
});

//Define an App Controller with some Angular features

app.controller("Shopfront", 
	['$scope', '$location', '$http', '$q', '$window', '$timeout', 
	function($scope, $location, $http, $q, $window, $timeout) {

		$scope.productLog = [];

		Shopfront.deployed()
		.then(function(_instance){
			$scope.contract = _instance; 
			console.log("The contract:", $scope.contract);

			$scope.productWatcher = $scope.contract.LogProductAddition({}, {fromBlock:0})
			.watch(function(err, newProduct){
				if (err){
					console.log("Error watching new product addition.", err);
				} else {
					console.log("New Product:", newProduct);
					newProduct.args.stock = newProduct.args.stock.toString(10);
					newProduct.args.price = newProduct.args.price.toString(10);
					newProduct.args.merchant = newProduct.args.merchant.toString(10);
					$scope.productLog.push(newProduct.args.merchant); 
					$scope.productLog.push(newProduct.args.stock);
					$scope.productLog.push(newProduct.args.price);
					$scope.getProductStatus();
					return $scope.getProductStatus();
				}
			})

			return $scope.getProductStatus();
		})

		$scope.addNewProduct = function(itemId, Price, Stock){
			if($scope.newProduct!=0) return; 
			console.log("newproduct", $scope.newProduct);
			var newProduct = $scope.newProduct; 
			$scope.newProduct = "";
			$scope.contract.addNewProduct({from: $scope.account, value: newProduct, gas: 900000})
			.then(function(txn){
				console.log("Transaction Receipt", txn);
				return $scope.getProductStatus(); 
			})
			.catch(function(error){
				console.log("Error processing new product", error);
			});
		}

		//Get the current products
		$scope.getProductStatus = function(){
			return $scope.contract.ourProducts({from: $scope.account})
			.then(function(_ourProducts){
				console.log("ourProducts", _ourProducts.toString(10));
				$scope.allTheProducts = _ourProducts.toString(10);
				return $scope.contract.ourProducts({from: $scope.account});
			})
		}
		
		//Work the first account
		web3.eth.getAccounts(function(err, accs){
			if(err != null){
				alert("There was an error fetching your accounts.")
				return;
			}
			if(accs.length == 0){
				alert("We could not find your accounts. Make sure Ethereum is configured correctly")
			}
			$scope.accounts = accs; 
			$scope.account = $scope.accounts[0];
			console.log("Using account:", $scope.account);

			web3.eth.getBalance($scope.account, function(err, _balance){
				$scope.balance = _balance.toString(10);
				console.log("The balance is", $scope.balance);
				$scope.balanceInEth = web3.fromWei($scope.balance, "ether");
				$scope.$apply();
			})

			
		})



	}]);