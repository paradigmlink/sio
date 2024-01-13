use crate::{Index, SingleAssignmentStore};

use core::hash::Hash;

///Enum representing an entry into a [SingleAssignmentStore]. May be either vacant or occupied.
/// created by [SingleAssignmentStore]::[`entry`].
///
/// [`entry`]: SingleAssignmentStore::entry
#[allow(dead_code)]
pub enum Entry<'a, K, V>
where
    K: Hash + Eq,
{
    Occupied(OccupiedEntry<'a, K, V>),
    Vacant(VacantEntry<'a, K, V>),
}
#[allow(dead_code)]
impl<'a, K, V> Entry<'a, K, V>
where
    K: Hash + Eq,
{
    ///Applies the provided function to the entry, if it is occupied.
    pub fn and_modify<F>(self, f: F) -> Self
    where
        F: FnOnce(&mut V),
    {
        match self {
            Self::Vacant(_) => self,
            Self::Occupied(mut entry) => {
                f(entry.get_mut());
                Self::Occupied(entry)
            }
        }
    }
    /// Inserts the provided value if the entry is vacant.
    pub fn or_insert(self, v: V) -> &'a mut V {
        match self {
            Self::Occupied(entry) => entry.into_mut(),
            Self::Vacant(entry) => entry.insert(v),
        }
    }
    /// Inserts the value produced by the provided function if the entry is vacant.
    pub fn or_insert_with<F>(self, f: F) -> &'a mut V
    where
        F: FnOnce() -> V,
    {
        match self {
            Self::Occupied(entry) => entry.into_mut(),
            Self::Vacant(entry) => entry.insert(f()),
        }
    }
    /// Inserts the value produced by the provided function if the entry is vacant.
    /// The function accepts a reference to the key as input.
    pub fn or_insert_with_key<F>(self, f: F) -> &'a mut V
    where
        F: FnOnce(&K) -> V,
    {
        match self {
            Self::Occupied(entry) => entry.into_mut(),
            Self::Vacant(entry) => {
                let value = f(entry.key());
                entry.insert(value)
            }
        }
    }
    ///Returns a reference to the key of this entry.
    pub fn key(&self) -> &K {
        match self {
            Self::Occupied(entry) => entry.key(),
            Self::Vacant(entry) => entry.key(),
        }
    }
}
#[allow(dead_code)]
impl<'a, K, V> Entry<'a, K, V>
where
    K: Hash + Eq,
    V: Default,
{
    /// Inserts a [Default] value if the entry is vacant.
    pub fn or_default(self) -> &'a mut V {
        match self {
            Self::Occupied(entry) => entry.into_mut(),
            Self::Vacant(entry) => entry.insert(Default::default()),
        }
    }
}

///An occupied entry into a [SingleAssignmentStore].
pub struct OccupiedEntry<'a, K, V>
where
    K: Hash + Eq,
{
    pub(crate) key: K,
    pub(crate) idx: Index,
    pub(crate) map: &'a mut SingleAssignmentStore<K, V>,
}
#[allow(dead_code)]
impl<'a, K, V> OccupiedEntry<'a, K, V>
where
    K: Hash + Eq,
{
    /// Returns a reference to the entry's key.
    pub fn key(&self) -> &K {
        &self.key
    }
    /// Removes the entry from the [SingleAssignmentStore], returning the key, and returning the
    ///  value if no other key references it.
    pub fn remove_entry(self) -> (K, Option<V>) {
        let key_ref = &self.key;
        let value = self.map.data.remove(&self.idx).map(|(_, v)| v);
        let key = self.map.keys.remove_entry(key_ref).map(|(k, _)| k).unwrap();
        (key, value)
    }
    /// Provides a shared reference to the value of the entry.
    pub fn get(&self) -> &V {
        self.map.data.get(&self.idx).map(|(_, v)| v).unwrap()
    }
    /// Provides a mutable reference to the value of the entry. If you need a reference
    /// that outlasts the lifetime of the entry, try using `[OccupiedEntry]::[`into_mut`].
    ///
    /// [`into_mut`]: OccupiedEntry::into_mut
    pub fn get_mut(&mut self) -> &mut V {
        self.map.data.get_mut(&self.idx).map(|(_, v)| v).unwrap()
    }
    /// Consumes the entry, returning a mutable reference to the value of the entry.
    pub fn into_mut(self) -> &'a mut V {
        self.map.data.get_mut(&self.idx).map(|(_, v)| v).unwrap()
    }
    /// Removes the entry from the [SingleAssignmentStore], and returns the
    ///  value if no other key references it.
    pub fn remove(self) -> Option<V> {
        let key = &self.key;
        self.map.remove(key)
    }
}
///A vacant entry into a [SingleAssignmentStore].
pub struct VacantEntry<'a, K, V>
where
    K: Hash + Eq,
{
    pub(crate) key: K,
    pub(crate) map: &'a mut SingleAssignmentStore<K, V>,
}
#[allow(dead_code)]
impl<'a, K, V> VacantEntry<'a, K, V>
where
    K: Hash + Eq,
{
    /// Returns a reference to the vacant entry's key.
    pub fn key(&self) -> &K {
        &self.key
    }
    /// Consumes the entry, returning the key provided to create it.
    pub fn into_key(self) -> K {
        self.key
    }
    /// Inserts the provided value at the vacant entry.
    pub fn insert(self, value: V) -> &'a mut V {
        let idx = self.map.next_index();
        self.map.keys.insert(self.key, idx);
        self.map.data.insert(idx, (1, value));
        self.map.data.get_mut(&idx).map(|(_, v)| v).unwrap()
    }
}
