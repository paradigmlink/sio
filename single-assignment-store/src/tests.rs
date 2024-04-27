#![cfg_attr(feature = "no_std", no_std)]
use crate::SingleAssignmentStore;

#[cfg(not(feature = "std"))]
//use alloc::vec::Vec;

#[cfg(not(feature = "std"))]
use alloc::string::String;

#[cfg(not(feature = "std"))]
use alloc::string::ToString;

#[test]
fn get_mut_test() {
    let mut map = SingleAssignmentStore::new();
    map.insert(1, "foo".to_string());
    let x = map.get_mut(&1).unwrap();
    *x = "bar".to_string();
    assert_eq!(Some(&"bar".to_string()), map.get(&1));
}

#[test]
fn insert_test() {
    let mut map = SingleAssignmentStore::new();
    map.insert(1, 2);
    assert_eq!(Some(&2), map.get(&1));
}

#[test]
fn insert_many_test() {
    let mut map = SingleAssignmentStore::new();
    map.insert_many(vec![1, 2], "foo".to_string());
    assert_eq!(Some(&"foo".to_string()), map.get(&1));
    assert_eq!(Some(&"foo".to_string()), map.get(&2));
}

#[test]
fn alias_test() {
    let mut map = SingleAssignmentStore::new();
    map.insert(1, 2);
    let result = map.alias(&1, 3);
    assert_eq!(result, Ok(&mut 2));
    assert_eq!(Some(&2), map.get(&3));
    let result = map.alias(&2, 4);
    assert_eq!(result, Err(4));
    assert_eq!(None, map.get(&4));
}

#[test]
fn alias_many_test() {
    let mut map = SingleAssignmentStore::new();
    map.insert(1, 2);
    let result = map.alias_many(&1, vec![3, 4, 5]);
    assert_eq!(result, Ok(&mut 2));
    assert_eq!(Some(&2), map.get(&3));
    assert_eq!(Some(&2), map.get(&4));
    assert_eq!(Some(&2), map.get(&5));
    let result = map.alias_many(&2, vec![6, 7, 8]);
    assert_eq!(result, Err(vec![6, 7, 8]));
    assert_eq!(None, map.get(&6));
    assert_eq!(None, map.get(&7));
    assert_eq!(None, map.get(&8));
}

#[test]
fn remove_test() {
    let mut map = SingleAssignmentStore::new();
    map.insert_many(vec![1, 2], 3);
    assert_eq!(None, map.remove(&1));
    assert_eq!(Some(3), map.remove(&2));
}

#[test]
fn remove_many_test() {
    let mut map = SingleAssignmentStore::new();
    map.insert(1, 2);
    map.insert(3, 4);
    assert_eq!(vec![2, 4], map.remove_many([&1, &3]));
}

#[test]
fn from_test() {
    let map = SingleAssignmentStore::from([(vec![1, 2], 3), (vec![4, 5], 6), (vec![7, 8, 9], 10)]);
    assert_eq!(Some(&3), map.get(&1));
    assert_eq!(Some(&3), map.get(&2));
    assert_eq!(Some(&6), map.get(&4));
    assert_eq!(Some(&6), map.get(&5));
    assert_eq!(Some(&10), map.get(&7));
    assert_eq!(Some(&10), map.get(&8));
    assert_eq!(Some(&10), map.get(&9));
}

#[test]
fn entry_insert_test() {
    let mut map = SingleAssignmentStore::from([(vec![1, 2], 3), (vec![4, 5], 6)]);
    map.entry(7).or_insert(-1);
    assert_eq!(Some(&-1), map.get(&7));
}

#[test]
fn entry_insert_with_test() {
    let mut map = SingleAssignmentStore::from([(vec![1, 2], 3), (vec![4, 5], 6)]);
    map.entry(7).or_insert_with(|| -1);
    assert_eq!(Some(&-1), map.get(&7));
}

#[test]
fn entry_insert_with_key_test() {
    let mut map = SingleAssignmentStore::from([(vec![1, 2], 3), (vec![4, 5], 6)]);
    map.entry(7).or_insert_with_key(|k| *k + 1);
    assert_eq!(Some(&8), map.get(&7));
}

#[test]
fn entry_modify_test() {
    let mut map = SingleAssignmentStore::from([(vec![1, 2], 3), (vec![4, 5], 6)]);
    map.entry(1).and_modify(|x| *x = *x + 1).or_insert(-1);
    assert_eq!(Some(&4), map.get(&1));
}

#[test]
fn entry_default_test() {
    let mut map = SingleAssignmentStore::from([
        (vec![1, 2], String::from("foo")),
        (vec![4, 5], String::from("bar")),
    ]);
    map.entry(7).or_default();
    assert_eq!(Some(&String::new()), map.get(&7));
}
