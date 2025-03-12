/// Interface representing `HelloContract`.
/// This interface allows modification and retrieval of the contract balance.
// #[starknet::interface]
// pub trait IHelloStarknet<TContractState> {
//     /// Increase contract balance.
//     fn increase_balance(ref self: TContractState, amount: felt252);
//     /// Retrieve contract balance.
//     fn get_balance(self: @TContractState) -> felt252;
// }

// /// Simple contract for managing balance.
// #[starknet::contract]
// mod HelloStarknet {
//     use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

//     #[storage]
//     struct Storage {
//         balance: felt252,
//     }

//     #[abi(embed_v0)]
//     impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
//         fn increase_balance(ref self: ContractState, amount: felt252) {
//             assert(amount != 0, 'Amount cannot be 0');
//             self.balance.write(self.balance.read() + amount);
//         }

//         fn get_balance(self: @ContractState) -> felt252 {
//             self.balance.read()
//         }
//     }
// }
// #[derive(Copy, Debug, Serde, Drop)]
// pub struct Book {
//     title: felt252,
//     author: felt252,
//     year: u16,
//     edition: felt252
// }
// 1. SchoolLibrary
        // - Add Books          Book { title, author, year, edition }
        // - Borrow Books
// 2. StudentRecord
        // - Borrow Books from SchoolLibrary

#[starknet::interface]
pub trait ISchoolLibrary<TContractState> {
    fn add_book(ref self: TContractState, book_name: felt252);
    fn borrow_book(ref self: TContractState, book_name: felt252) -> bool;
}

#[starknet::contract]
mod SchoolLibrary {
    use starknet::event::EventEmitter;
    use starknet::storage::{Map, StoragePointerWriteAccess, StoragePointerReadAccess, StoragePathEntry};
    // use super::Book;

    #[storage]
    struct Storage {
        book_record: Map<felt252, bool> // Map<Book, bool> // entry <-> write
    }

    #[event]
    #[derive(Copy, Drop, starknet::Event)]
    enum Event {
        AddBook: AddBook
    }

    #[derive(Copy, Drop, starknet::Event)]
    struct AddBook {
        book_name: felt252,
        response: felt252,
    }

    #[abi(embed_v0)]
    impl SchoolLibraryImpl of super::ISchoolLibrary<ContractState> {
        fn add_book(ref self: ContractState, book_name: felt252 ) {
            self.book_record.entry(book_name).write(true);

            self.emit(
                AddBook {
                    book_name,
                    response: 'Book has been added'
                }
            )
        }
        fn borrow_book(ref self: ContractState, book_name: felt252) -> bool {
            let book_exists = self.book_record.entry(book_name).read();

            if book_exists {
                return true;
            } else {
                return false;
            }
        }
    }
}

// 2. StudentRecord
        // - Borrow Books from SchoolLibrary
use core::starknet::ContractAddress;

#[starknet::interface]
pub trait IStudentRecord<TContractState> {
    fn borrow_book_from_lib(ref self: TContractState, book_name: felt252, student_name: felt252, lib_address: ContractAddress) -> bool;
}

#[starknet::contract]
mod StudentRecord {
    use starknet::storage::StorageMapWriteAccess;
    use super::IStudentRecord;
    use super::ISchoolLibraryDispatcherTrait;
    use starknet::storage::{Map};
    use super::ISchoolLibraryDispatcher;
    use core::starknet::ContractAddress;

    #[storage]
    struct Storage {
        borrow_books: Map<felt252, felt252> // student_name => book_name
    }

    impl StudentRecordImpl of super::IStudentRecord<ContractState> {
        fn borrow_book_from_lib(ref self: ContractState, book_name: felt252, student_name: felt252, lib_address: ContractAddress) -> bool {
            let lib_dispatcher = ISchoolLibraryDispatcher { contract_address: lib_address };

            let check = lib_dispatcher.borrow_book(book_name);

            if check {
                self.borrow_books.write(student_name, book_name);
                return true;
            } else {
                return false;
            }
        }
    }
}