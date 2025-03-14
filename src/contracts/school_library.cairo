use crate::interfaces::ischool_library::ISchoolLibrary;

#[starknet::contract]
pub mod SchoolLibrary {
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