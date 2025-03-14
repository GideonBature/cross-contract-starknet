use starknet::ContractAddress;

#[starknet::interface]
pub trait IStudentRecord<TContractState> {
    fn borrow_book_from_lib(ref self: TContractState, book_name: felt252, student_name: felt252, lib_address: ContractAddress) -> bool;
}