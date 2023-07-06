module TestStorageExt
using ..DataStore: AbstractStorage
mutable struct TestStorage <: AbstractStorage
    data::Any
end
create_storage() = TestStorage(nothing)
end
