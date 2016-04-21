module mEmDee

use, intrinsic :: iso_c_binding

implicit none

type, bind(C) :: tEmDee

  integer(c_int) :: builds    ! Number of neighbor-list builds
  type(c_ptr)    :: first     ! First neighbor of each atom
  type(c_ptr)    :: last      ! Last neighbor of each atom 
  type(c_ptr)    :: neighbor  ! List of neighbors

  real(c_double) :: time, checktime ! APAGAR DEPOIS DE TESTAR

  integer(c_int) :: natoms    ! Number of atoms
  integer(c_int) :: nx3       ! Three times the number of atoms
  integer(c_int) :: npairs    ! Number of neighbor pairs
  integer(c_int) :: maxpairs  ! Maximum number of neighbor pairs
  integer(c_int) :: mcells    ! Number of cells at each dimension
  integer(c_int) :: ncells    ! Total number of cells
  integer(c_int) :: maxcells  ! Maximum number of cells

  real(c_double) :: Rc        ! Cut-off distance
  real(c_double) :: RcSq      ! Cut-off distance squared
  real(c_double) :: xRc       ! Extended cutoff distance (including skin)
  real(c_double) :: xRcSq     ! Extended cutoff distance squared
  real(c_double) :: skinSq    ! Square of the neighbor list skin width

  type(c_ptr)    :: cell
  type(c_ptr)    :: next      ! Next atom in a linked list of atoms

  type(c_ptr)    :: type      ! Atom types
  type(c_ptr)    :: R0        ! Atom positions at list building
  type(c_ptr)    :: R         ! Pointer to dynamic atom positions
  type(c_ptr)    :: P         ! Pointer to dynamic atom momenta
  type(c_ptr)    :: F

  integer(c_int) :: ntypes
  type(c_ptr)    :: pairType
  type(c_ptr)    :: invmass

  real(c_double) :: Energy
  real(c_double) :: Virial

end type tEmDee

interface

  subroutine md_initialize( me, rc, skin, atoms, types, type_index, mass ) bind(C)
    import :: c_ptr, c_int, c_double
    type(c_ptr),    value :: me
    real(c_double), value :: rc, skin
    integer(c_int), value :: atoms, types
    type(c_ptr),    value :: type_index, mass
  end subroutine md_initialize

  subroutine md_set_lj( me, i, j, sigma, epsilon ) bind(C)
    import :: c_ptr, c_int, c_double
    type(c_ptr),    value :: me
    integer(c_int), value :: i, j
    real(c_double), value :: sigma, epsilon
  end subroutine md_set_lj

  subroutine md_set_shifted_force_lj( me, i, j, sigma, epsilon ) bind(C)
    import :: c_ptr, c_int, c_double
    type(c_ptr),    value :: me
    integer(c_int), value :: i, j
    real(c_double), value :: sigma, epsilon
  end subroutine md_set_shifted_force_lj

  subroutine md_upload( me, coords, momenta ) bind(C)
    import :: c_ptr
    type(c_ptr), value :: me, coords, momenta
  end subroutine md_upload

  subroutine md_download( me, coords, momenta, forces ) bind(C)
    import :: c_ptr
    type(c_ptr), value :: me, coords, momenta, forces
  end subroutine md_download

  subroutine md_change_coordinates( me, a, b ) bind(C)
    import :: c_ptr, c_double
    type(c_ptr),    value :: me
    real(c_double), value :: a, b
  end subroutine md_change_coordinates

  subroutine md_change_momenta( me, a, b ) bind(C)
    import :: c_ptr, c_double
    type(c_ptr),    value :: me
    real(c_double), value :: a, b
  end subroutine md_change_momenta

  subroutine md_compute_forces( me, L ) bind(C)
    import :: c_ptr, c_double
    type(c_ptr),    value :: me
    real(c_double), value :: L
  end subroutine md_compute_forces

end interface

contains

!---------------------------------------------------------------------------------------------------

  subroutine fmd_initialize( me, rc, skin, atoms, types, type_index, mass ) bind(C)
    type(c_ptr),    value :: me
    real(c_double), value :: rc, skin
    integer(c_int), value :: atoms, types
    type(c_ptr),    value :: type_index, mass
  end subroutine fmd_initialize

!---------------------------------------------------------------------------------------------------

end module mEmDee
