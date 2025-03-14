use crate::interfaces::{ischool_library::{ISchoolLibraryDispatcher, ISchoolLibraryDispatcherTrait}, istudent_record::IStudentRecord};

#[starknet::contract]
pub mod StudentRecord {
    use starknet::storage::StorageMapWriteAccess;
    use super::ISchoolLibraryDispatcherTrait;
    use starknet::storage::{Map};
    use super::ISchoolLibraryDispatcher;
    use starknet::ContractAddress;

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