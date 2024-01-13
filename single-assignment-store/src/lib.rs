//#![cfg_attr(feature = "no_std", no_std)]
#![no_std]
//! Provides [SingleAssignmentStore], an associative array that can share one value
//! across multiple keys without [`Rc`], and provides mutable access
//! that will never panic at runtime, unlike [`RefCell`].
//!
//! ```
//! use single_assignment_store::SingleAssignmentStore;
//!
//! let mut map: SingleAssignmentStore<i32, String> = SingleAssignmentStore::from([
//!     (vec![1, 2, 3], "foo".into()),
//!     (vec![4, 5], "bar".into()),
//! ]);
//! map.insert_many(vec![6, 7], "quux".into());
//! map.alias(&7, 8);
//! assert_eq!(map.get(&8), Some(&String::from("quux")));
//! ```
//!
//! [`Rc`]: std::rc::Rc
//!
//! [`RefCell`]: std::cell::RefCell


#[macro_use]
extern crate alloc;
extern crate hashbrown;

use core::hash::Hash;
pub use entry::{Entry, OccupiedEntry, VacantEntry};
pub use iter::Iter;
use core::borrow::Borrow;
use core::fmt::Debug;
use hashbrown::HashMap;
use alloc::vec::Vec;
use alloc::fmt;

/// Provides types and methods for the Entry API. for more information, see [`entry`] for more info.
///
/// [`entry`]: SingleAssignmentStore::entry
pub mod entry;
/// Provides [`Iter`], an iterator over all keys and values. see [`iter`] for more info.
///
/// [`Iter`]: iter::Iter
///
/// [`iter`]: SingleAssignmentStore::iter
pub mod iter;
#[cfg(test)]
mod tests;

//u128 allows us to not store freed indices and keep removal O(1);
//as many as 10 trillion inserts/removes per second
//would still take ~10^18 years to use up the available index space
#[derive(Hash, PartialEq, Eq, Clone, Copy)]
struct Index(u128);

#[derive(Clone)]
/// A wrapper over [HashMap] that allows for multiple keys to point to a single element,
/// providing some additional utilities to make working with multiple keys easier.
pub struct SingleAssignmentStore<K, V>
where
    K: Hash + Eq,
{
    /// A wrapper over [HashMap] that allows for multiple keys to point to a single element,
    /// providing some additional utilities to make working with multiple keys easier.
    keys: HashMap<K, Index>,
    data: HashMap<Index, (usize, V)>,
    max_index: Index,
}

impl<K, V> Default for SingleAssignmentStore<K, V>
where
    K: Hash + Eq,
{
    fn default() -> Self {
        SingleAssignmentStore {
            keys: HashMap::new(),
            data: HashMap::new(),
            max_index: Index(0),
        }
    }
}
#[allow(dead_code)]
impl<K, V> SingleAssignmentStore<K, V>
where
    K: Hash + Eq,
{
    ///Creates an empty [SingleAssignmentStore].
    pub fn new() -> Self {
        Default::default()
    }

    pub(crate) fn next_index(&mut self) -> Index {
        let idx = self.max_index;
        self.max_index = Index(self.max_index.0 + 1);
        idx
    }

    pub fn contains_key<Q: ?Sized>(&self, k: &Q) -> bool
    where
        K: Borrow<Q>,
        Q: Hash + Eq,
    {
        self.keys.contains_key(k)
    }

    ///inserts a new value at a given key, and returns the value at that key if
    /// there are no other keys to that value. otherwise returns [`None`].
    pub fn insert(&mut self, k: K, v: V) -> Option<V> {
        if self.contains_key(&k) {
            let idx = self.keys.get(&k).unwrap();
            let (count, _) = self.data.get_mut(idx).unwrap();
            if *count <= 1 {
                self.data.insert(*idx, (1, v)).map(|(_, v)| v)
            } else {
                *count -= 1;
                let new_idx = self.max_index;
                self.max_index = Index(self.max_index.0 + 1);
                self.keys.insert(k, new_idx);
                self.data.insert(new_idx, (1, v));
                None
            }
        } else {
            let new_idx = self.max_index;
            self.max_index = Index(self.max_index.0 + 1);
            self.keys.insert(k, new_idx);
            self.data.insert(new_idx, (1, v));
            None
        }
    }
    ///Attempts to add a new key to the element at `k`. Returns the new key if `k` is not
    /// in the map.
    /// ```
    /// use single_assignment_store::SingleAssignmentStore;
    /// let mut map = SingleAssignmentStore::from([
    ///     (vec!["foo".to_string()], 1),
    ///     (vec!["quux".to_string()], -2),
    /// ]);
    /// let aliased = map.alias("foo", "bar".to_string());
    /// assert_eq!(aliased, Ok(&mut 1));
    /// let aliased = map.alias("baz", "xyz".to_string());
    /// assert_eq!(aliased, Err("xyz".to_string()));
    /// ```
    pub fn alias<Q: ?Sized>(&mut self, k: &Q, alias: K) -> Result<&mut V, K>
    where
        K: Borrow<Q>,
        Q: Hash + Eq,
    {
        if self.contains_key(k) {
            let idx = *self.keys.get(k).unwrap();
            let (count, v) = self.data.get_mut(&idx).unwrap();
            *count += 1;
            self.keys.insert(alias, idx);
            Ok(v)
        } else {
            Err(alias)
        }
    }
    ///Attempts to add multiple new keys to the element at `k`. Returns the list of keys if `k` is not
    /// in the map.
    /// ```
    /// use single_assignment_store::SingleAssignmentStore;
    /// let mut map = SingleAssignmentStore::from([
    ///     (vec!["foo".to_string()], 1),
    /// ]);
    /// let aliased = map.alias_many("foo", vec!["bar".to_string(), "quux".to_string()]);
    /// assert_eq!(aliased, Ok(&mut 1));
    /// let aliased = map.alias_many("baz", vec!["xyz".to_string(), "syzygy".to_string()]);
    /// assert_eq!(aliased, Err(vec!["xyz".to_string(), "syzygy".to_string()]));
    /// ```
    pub fn alias_many<Q: ?Sized>(&mut self, k: &Q, aliases: Vec<K>) -> Result<&mut V, Vec<K>>
    where
        K: Borrow<Q>,
        Q: Hash + Eq,
    {
        if self.contains_key(k) {
            let idx = *self.keys.get(k).unwrap();
            let (count, v) = self.data.get_mut(&idx).unwrap();
            for alias in aliases {
                *count += 1;
                self.keys.insert(alias, idx);
            }
            Ok(v)
        } else {
            Err(aliases)
        }
    }
    ///An iterator visiting all keys in an arbitrary order. Equivalent to [HashMap]::[`keys`].
    ///
    /// [`keys`]: HashMap::keys
    pub fn keys(&self) -> impl Iterator<Item = &K> {
        self.keys.keys()
    }
    ///An iterator visiting all elements in an arbitrary order. Equivalent to [HashMap]::[`values`].
    ///
    /// [`values`]: HashMap::values
    pub fn values(&self) -> impl Iterator<Item = &V> {
        self.data.values().map(|(_, v)| v)
    }
    ///An iterator visiting all elements in an arbitrary order, while allowing mutation. Equivalent to [HashMap]::[`values_mut`].
    ///
    /// [`values_mut`]: HashMap::values_mut
    pub fn values_mut(&mut self) -> impl Iterator<Item = &mut V> {
        self.data.values_mut().map(|(_, v)| v)
    }
    ///Consumes the map and provides an iterator over all keys. Equivalent to [HashMap]::[`into_keys`].
    ///
    /// [`into_keys`]: HashMap::into_keys
    pub fn into_keys(self) -> impl Iterator<Item = K> {
        self.keys.into_keys()
    }
    ///Consumes the map and provides an iterator over all values. Equivalent to [HashMap]::[`into_values`].
    ///
    /// [`into_values`]: HashMap::into_values
    pub fn into_values(self) -> impl Iterator<Item = V> {
        self.data.into_values().map(|(_, v)| v)
    }
    ///An iterator visiting all key-value pairs. Due to the nature of [SingleAssignmentStore], value references
    /// may be shared across multiple keys.
    pub fn iter(&self) -> impl Iterator<Item = (&K, &V)> {
        iter::Iter::new(self)
    }
    ///Returns a shared reference to the value of the key. Equivalent to [HashMap]::[`get`].
    ///
    /// [`get`]: HashMap::get
    pub fn get<Q: ?Sized>(&self, k: &Q) -> Option<&V>
    where
        K: Borrow<Q>,
        Q: Hash + Eq,
    {
        self.keys
            .get(k)
            .and_then(|idx| self.data.get(idx))
            .map(|(_, v)| v)
    }
    ///Returns a mutable reference to the value of the key. Equivalent to [HashMap]::[`get_mut`].
    ///
    /// ```
    /// use single_assignment_store::SingleAssignmentStore;
    /// let mut map = SingleAssignmentStore::new();
    /// map.insert(1, "foo".to_string());
    /// let x = map.get_mut(&1).unwrap();
    /// *x = "bar".to_string();
    /// assert_eq!(Some(&"bar".to_string()), map.get(&1));
    /// ```
    /// [`get_mut`]: HashMap::get_mut
    pub fn get_mut<Q: ?Sized>(&mut self, k: &Q) -> Option<&mut V>
    where
        K: Borrow<Q>,
        Q: Hash + Eq,
    {
        self.keys
            .get(k)
            .and_then(|idx| self.data.get_mut(idx))
            .map(|(_, v)| v)
    }
    ///inserts a new value, pairs it to a list of keys, and returns the values that existed
    /// at each key if there are no other keys to that value.
    /// ```
    /// use single_assignment_store::SingleAssignmentStore;
    /// let mut map = SingleAssignmentStore::new();
    /// map.insert_many(vec![1, 2],"foo".to_string());
    /// assert_eq!(Some(&"foo".to_string()), map.get(&1));
    /// assert_eq!(Some(&"foo".to_string()), map.get(&2));
    /// ```
    pub fn insert_many(&mut self, ks: Vec<K>, v: V) -> Vec<V> {
        let mut bumped = vec![];
        let new_idx = self.max_index;
        self.max_index = Index(self.max_index.0 + 1);
        let mut new_count = 0;
        for k in ks {
            if self.contains_key(&k) {
                let idx = self.keys.get(&k).unwrap();
                let (count, _) = self.data.get_mut(idx).unwrap();
                if *count <= 1 {
                    if let Some((_, v)) = self.data.remove(idx) {
                        bumped.push(v);
                    }
                } else {
                    *count -= 1;
                    new_count += 1;
                    self.keys.insert(k, new_idx);
                }
            } else {
                new_count += 1;
                self.keys.insert(k, new_idx);
            }
        }
        self.data.insert(new_idx, (new_count, v));
        bumped
    }
    ///Removes a key from the map, returning the value at that key if it existed in the map
    /// and no other keys share that value.
    pub fn remove<Q: ?Sized>(&mut self, k: &Q) -> Option<V>
    where
        K: Borrow<Q>,
        Q: Hash + Eq,
    {
        if self.contains_key(k) {
            let idx = self.keys.get(k).unwrap();
            let (count, _) = self.data.get_mut(idx).unwrap();
            if *count == 1 {
                let result = self.data.remove(idx).map(|(_, v)| v);
                self.keys.remove(k);
                result
            } else {
                *count -= 1;
                self.keys.remove(k);
                None
            }
        } else {
            None
        }
    }
    ///Removes a list of keys from the map, returning the values at each key if they existed in the map
    /// and no other keys shared that value.
    pub fn remove_many<Q: ?Sized, const N: usize>(&mut self, ks: [&Q; N]) -> Vec<V>
    where
        K: Borrow<Q>,
        Q: Hash + Eq,
    {
        let mut bumped = vec![];
        for k in ks {
            if let Some(v) = self.remove(k) {
                bumped.push(v);
            }
        }
        bumped
    }
    ///Equivalent to [HashMap]::[`entry`].
    ///
    /// [`entry`]: HashMap::entry
    pub fn entry(&mut self, k: K) -> Entry<K, V> {
        if let Some(idx) = self.keys.get(&k) {
            Entry::Occupied(OccupiedEntry {
                key: k,
                idx: *idx,
                map: self,
            })
        } else {
            Entry::Vacant(VacantEntry { key: k, map: self })
        }
    }
}

impl<K, V, const N: usize> From<[(Vec<K>, V); N]> for SingleAssignmentStore<K, V>
where
    K: Hash + Eq,
{
    fn from(arr: [(Vec<K>, V); N]) -> Self {
        Self::from_iter(arr)
    }
}

impl<K, V> FromIterator<(Vec<K>, V)> for SingleAssignmentStore<K, V>
where
    K: Hash + Eq,
{
    fn from_iter<T: IntoIterator<Item = (Vec<K>, V)>>(iter: T) -> Self {
        let mut map = Self::new();
        for (keys, value) in iter {
            map.insert_many(keys, value);
        }
        map
    }
}

impl<K, V> PartialEq for SingleAssignmentStore<K, V>
where
    K: Hash + Eq,
    V: PartialEq,
{
    fn eq(&self, rhs: &Self) -> bool {
        if self.keys.len() != rhs.keys.len() || self.data.len() != rhs.data.len() {
            return false;
        }
        self.iter()
            .all(|(key, value)| rhs.get(key).map_or(false, |v| *value == *v))
    }
}

impl<K, V> Eq for SingleAssignmentStore<K, V>
where
    K: Hash + Eq,
    V: Eq,
{
}

impl<K, V> Debug for SingleAssignmentStore<K, V>
where
    K: Hash + Eq + Debug,
    V: Debug
{
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_map().entries(self.iter()).finish()
    }
}

impl<'a, K, V> Extend<(&'a [K], &'a V)> for SingleAssignmentStore<K, V>
where
    K: Hash + Eq + Copy,
    V: Copy,
{
    fn extend<T: IntoIterator<Item = (&'a [K], &'a V)>>(&mut self, iter: T) {
        for (ks, v) in iter {
            self.insert_many(ks.to_vec(), *v);
        }
    }
}

impl<K, V> Extend<(Vec<K>, V)> for SingleAssignmentStore<K, V>
where
    K: Hash + Eq,
{
    fn extend<T: IntoIterator<Item = (Vec<K>, V)>>(&mut self, iter: T) {
        for (ks, v) in iter {
            self.insert_many(ks, v);
        }
    }
}
