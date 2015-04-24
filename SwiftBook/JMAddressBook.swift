//
//  JMAddressBook.swift
//  Retrieving All the People in the Address Book
//
//  Created by Jake Mor on 3/7/15.
//  Copyright (c) 2015 Pixolity Ltd. All rights reserved.
//

import Foundation
import AddressBook

class JMAddressBook {
    
    init() {
        
    }
    
    func askPermission(callbackSuccess:()->(), callbackFail:()->()) {
        var addressBook: ABAddressBookRef = {
            var error: Unmanaged<CFError>?
            return ABAddressBookCreateWithOptions(nil,
                &error).takeRetainedValue() as ABAddressBookRef
            }()
        
        ABAddressBookRequestAccessWithCompletion(addressBook,
            {(granted: Bool, error: CFError!) in
                
                if granted{
                    println("Access is granted")
                    dispatch_async(dispatch_get_main_queue()) {
                        callbackSuccess()
                    }
                } else {
                    println("Access is not granted")
                    dispatch_async(dispatch_get_main_queue()) {
                        callbackFail()
                    }
                }
        })
    }

    func getFullAB() -> [ABRecordRef] {
        var emptyArray: [ABRecordRef] = []
        
        var addressBook: ABAddressBookRef = {
            var error: Unmanaged<CFError>?
            return ABAddressBookCreateWithOptions(nil,
                &error).takeRetainedValue() as ABAddressBookRef
            }()
        
        switch ABAddressBookGetAuthorizationStatus(){
        case .Authorized:
            println("Already authorized")
            emptyArray = getAB(addressBook)
        case .Denied:
            println("You are denied access to address book")
            
        case .NotDetermined:
            
            ABAddressBookRequestAccessWithCompletion(addressBook,
                {(granted: Bool, error: CFError!) in
                    
                    if granted{
                        println("Access is granted")
                        emptyArray = self.getAB(addressBook)
                    } else {
                        println("Access is not granted")
                    }
            })
        case .Restricted:
            println("Access is restricted")
        default:
            println("Unhandled")
        }
        println("====AB DELIVERED====")
        return emptyArray
    }
    
    func getNumbers() -> [[String]] {
        var emptyArray: [[String]] = []
        
        var addressBook: ABAddressBookRef = {
            var error: Unmanaged<CFError>?
            return ABAddressBookCreateWithOptions(nil,
                &error).takeRetainedValue() as ABAddressBookRef
            }()
        
        switch ABAddressBookGetAuthorizationStatus(){
        case .Authorized:
            println("Already authorized")
            emptyArray = readFromAddressBook(addressBook)
        case .Denied:
            println("You are denied access to address book")
        
        case .NotDetermined:
           
            ABAddressBookRequestAccessWithCompletion(addressBook,
                {(granted: Bool, error: CFError!) in
                    
                    if granted{
                        println("Access is granted")
                        emptyArray = self.readFromAddressBook(addressBook)
                    } else {
                        println("Access is not granted")
                    }
            })
        case .Restricted:
            println("Access is restricted")
        default:
            println("Unhandled")
        }
        
        return emptyArray
    }
    
    func sanitize(phone:String)->String {
        
        let digits = ["0","1","2","3","4","5","6","7","8","9"]
        
        var phoneArray:[String] = []
        
        for c in phone {
            if contains(digits, "\(c)") {
                phoneArray.append("\(c)")
            }
        }
        
        var newText:String = ""
        
        for var i = 0; i < phoneArray.count; i++ {
            var index = phoneArray.count - i - 1
            if (i < 10) {
                newText = phoneArray[index] + newText
            }
        }
        
        return newText
    }
    
    func readFromAddressBook(addressBook: ABAddressBookRef) -> [[String]] {
        
        /* Get all the people in the address book */
  //      let allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray

        var source:ABRecord = ABAddressBookCopyDefaultSource(addressBook).takeRetainedValue()
        var allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook,
            source, ABPersonSortOrdering(kABPersonSortByFirstName)).takeRetainedValue() as [ABRecord]

        
        var array: [[String]] = []
        var unique = NSMutableSet()
        var i = 0;
        
        for person: ABRecordRef in allPeople{
            // Get the first and last name of the contact
            let fname:String = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as String? ?? ""
            let lname:String! = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as String? ?? ""
            
            /* Get all the phone numbers this user has*/
            let unmanagedPhones = ABRecordCopyValue(person, kABPersonPhoneProperty)
            let phones: ABMultiValueRef =
            Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue()
                as NSObject as ABMultiValueRef
            let countOfPhones = ABMultiValueGetCount(phones)
            
            for index in 0..<countOfPhones{
                var contact: [String] = []
                
                let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, index)
                var phone: String = Unmanaged.fromOpaque(
                    unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as String
                
                phone = sanitize(phone)
                
                if (countElements(phone) == 10) {
                    
                    if (unique.containsObject(phone)) {
                        
                    } else {
                        unique.addObject(phone)
                        contact.append(phone)
                        contact.append(fname)
                        contact.append(lname)
                        array.append(contact)
                        i++
                    }
                }
            }
        }
        
        println("====UNIQUE CONTACTS FOUND====")
        println(i)
        println()
        
        return array
    }
    
    func getAB(addressBook: ABAddressBookRef) -> [ABRecordRef] {
        
        /* Get all the people in the address book */
        let allPeople = ABAddressBookCopyArrayOfAllPeople(
            addressBook).takeRetainedValue() as NSArray
        
        println(allPeople[0])
        
        return allPeople
    }

    
}