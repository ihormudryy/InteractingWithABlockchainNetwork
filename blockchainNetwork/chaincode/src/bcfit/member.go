/*
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
*/

package main

import (
	"encoding/json"
	"strconv"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

// ============================================================================================================================
// Create member
// Inputs - id, type(user or seller)
// ============================================================================================================================
func (t *SimpleChaincode) createMember(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments")
	}

	//get id and type from args
	member_id := args[0]
	member_type := strings.ToLower(args[1])

	//check if type is 'user'
	if member_type == TYPE_USER {

		//create user
		var user User
		user.Id = member_id
		user.Type = TYPE_USER
		user.CryptocoinsBalance = 0
		user.StepsUsedForConversion = 0
		user.TotalSteps = 0

		//store user
		userAsBytes, _ := json.Marshal(user)
		err = stub.PutState(user.Id, userAsBytes)
		if err != nil {
			return shim.Error(err.Error())
		}

		//return user info
		return shim.Success(userAsBytes)

	} else if member_type == TYPE_SELLER {
		//check if type is 'seller'

		//create seller
		var seller Seller
		seller.Id = member_id
		seller.Type = TYPE_SELLER
		seller.CryptocoinsBalance = 0

		// store seller
		sellerAsBytes, _ := json.Marshal(seller)
		err = stub.PutState(seller.Id, sellerAsBytes)
		if err != nil {
			return shim.Error(err.Error())
		}

		//get and update sellerIDs
		sellerIdsBytes, err := stub.GetState("sellerIds")
		if err != nil {
			return shim.Error("Unable to get users.")
		}
		var sellerIds []string
		// add sellerID to update sellers
		json.Unmarshal(sellerIdsBytes, &sellerIds)
		sellerIds = append(sellerIds, seller.Id)
		updatedSellerIdsBytes, _ := json.Marshal(sellerIds)
		err = stub.PutState("sellerIds", updatedSellerIdsBytes)

		//return seller info
		return shim.Success(sellerAsBytes)

	}

	return shim.Success(nil)

}

// ============================================================================================================================
// Generate ${COIN_NAME}s for the user using user steps
// Inputs - userId, transactionSteps
// ============================================================================================================================
func (t *SimpleChaincode) generateCryptocoins(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments")
	}
	var err error

	//get user_id and newSteps from args
	user_id := args[0]
	newTransactionSteps, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error(err.Error())
	}

	//get user
	var user User
	userAsBytes, err := stub.GetState(user_id)
	if err != nil {
		return shim.Error("Failed to get user")
	}
	json.Unmarshal(userAsBytes, &user)
	if user.Type != TYPE_USER {
		return shim.Error("Not user type")
	}

	//update user account
	var newSteps = newTransactionSteps - user.StepsUsedForConversion
	var newCryptocoins = 0
	if newSteps >= STEPS_TO_COIN_NAME {
		newCryptocoins = newSteps / STEPS_TO_COIN_NAME
		var remainderSteps = newSteps % STEPS_TO_COIN_NAME
		user.CryptocoinsBalance = user.CryptocoinsBalance + newCryptocoins
		user.StepsUsedForConversion = newTransactionSteps - remainderSteps
		user.TotalSteps = newTransactionSteps

		//update users state
		updatedUserAsBytes, _ := json.Marshal(user)
		err = stub.PutState(user_id, updatedUserAsBytes)
		if err != nil {
			return shim.Error(err.Error())
		}
	}

	//return updated user with GeneratedCryptocoins and GeneratedSteps
	type ReturnUser struct {
		User
		GeneratedCryptocoins			 int      `json:"generatedCryptocoins"`
	}
	var returnUser ReturnUser

	returnUser.Id = user.Id
	returnUser.Type = user.Type
	returnUser.CryptocoinsBalance = user.CryptocoinsBalance
	returnUser.TotalSteps = user.TotalSteps
	returnUser.StepsUsedForConversion = user.StepsUsedForConversion
	returnUser.ContractIds = user.ContractIds
	returnUser.GeneratedCryptocoins = newCryptocoins

	returnUserBytes, _ := json.Marshal(returnUser)
	return shim.Success(returnUserBytes)

}


// ============================================================================================================================
// Award ${COIN_NAME}s to user
// Inputs - userId, newCryptocoins
// ============================================================================================================================
func (t *SimpleChaincode) awardCryptocoins(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments")
	}
	var err error

	//get user_id and ${COIN_NAME}s from args
	user_id := args[0]
	newCryptocoins, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error(err.Error())
	}

	//check newCryptocoins arg
	if (newCryptocoins < 0) {
		return shim.Error("Must be positive")
	}

	//get user
	var user User
	userAsBytes, err := stub.GetState(user_id)
	if err != nil {
		return shim.Error("Failed to get user")
	}
	json.Unmarshal(userAsBytes, &user)
	if user.Type != TYPE_USER {
		return shim.Error("Not user type")
	}

	user.CryptocoinsBalance = user.CryptocoinsBalance + newCryptocoins

	//update users state
	updatedUserAsBytes, _ := json.Marshal(user)
	err = stub.PutState(user_id, updatedUserAsBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	//return updated user with GeneratedCryptocoins
	type ReturnUser struct {
		User
		GeneratedCryptocoins			 int      `json:"generatedCryptocoins"`
	}
	var returnUser ReturnUser

	returnUser.Id = user.Id
	returnUser.Type = user.Type
	returnUser.CryptocoinsBalance = user.CryptocoinsBalance
	returnUser.TotalSteps = user.TotalSteps
	returnUser.StepsUsedForConversion = user.StepsUsedForConversion
	returnUser.ContractIds = user.ContractIds
	returnUser.GeneratedCryptocoins = newCryptocoins

	returnUserBytes, _ := json.Marshal(returnUser)
	return shim.Success(returnUserBytes)

}
