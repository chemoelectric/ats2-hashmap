/*

Copyright © 2021 Barry Schwartz

This program is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License, as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received copies of the GNU General Public License
along with this program. If not, see
<https://www.gnu.org/licenses/>.

*/

#ifndef ATS2_HASHMAP_CATS_SPINLOCK_CATS_HEADER_GUARD__
#define ATS2_HASHMAP_CATS_SPINLOCK_CATS_HEADER_GUARD__

#include <stdatomic.h>
#include "hashmap/CATS/atomic.cats"

/********************************************************************/

#ifdef __GNUC__

/*
 * FIXME: Similar things can be done for other platforms and other
 *        compilers.
 */
#if defined(__i386__) || defined(__x86_64__)
#define ats2_hashmap_pause() __builtin_ia32_pause ()
#endif

#else

#define ats2_hashmap_pause() do { /* nothing */ } while (0)

#endif

/********************************************************************/

typedef struct
{
  /* Use unsigned integers, so they will wrap around when they
     overflow. */
  ats2_hashmap_atomic_size_t active;
  ats2_hashmap_atomic_size_t available;
} ats2_hashmap_spinlock_struct_t;

typedef ats2_hashmap_spinlock_struct_t *ats2_hashmap_spinlock_t;

ATSinline() ats2_hashmap_spinlock_t
ats2_hashmap_spinlock_alloc (void)
{
  ats2_hashmap_spinlock_t lock =
    ATS_MALLOC (sizeof (ats2_hashmap_spinlock_struct_t));
  lock->active = 0;
  lock->available = 0;
  return lock;
}

ATSinline() void
ats2_hashmap_spinlock_free (ats2_hashmap_spinlock_t lock)
{
  ATS_MFREE (lock);
}

ATSinline() ats2_hashmap_spinlock_struct_t
ats2_hashmap_spinlock_data (void)
{
  ats2_hashmap_spinlock_struct_t lock;
  lock.active = 0;
  lock.available = 0;
  return lock;
}

ATSinline() ats2_hashmap_atomic_size_t_ptr
ats2_hashmap_spinlock_active_p (ats2_hashmap_spinlock_t lock)
{
  return &(lock->active);
}

ATSinline() ats2_hashmap_atomic_size_t_ptr
ats2_hashmap_spinlock_available_p (ats2_hashmap_spinlock_t lock)
{
  return &(lock->available);
}

/********************************************************************/

#endif /* ATS2_HASHMAP_CATS_SPINLOCK_CATS_HEADER_GUARD__ */
