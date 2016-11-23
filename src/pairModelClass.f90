!   This file is part of EmDee.
!
!    EmDee is free software: you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    EmDee is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with EmDee. If not, see <http://www.gnu.org/licenses/>.
!
!    Author: Charlles R. A. Abreu (abreu@eq.ufrj.br)
!            Applied Thermodynamics and Molecular Simulation
!            Federal University of Rio de Janeiro, Brazil

module pairModelClass

use global
use modelClass

implicit none

!> An abstract class for pair interaction models:
type, abstract, extends(cModel) :: cPairModel
  character(10) :: kind
  logical :: shifted_force_vdw = .false.
  logical :: shifted_force_coul = .false.
  real(rb) :: eshift_vdw = zero
  real(rb) :: fshift_vdw = zero
  real(rb) :: eshift_coul = zero
  real(rb) :: fshift_coul = zero
  contains
    procedure(cPairModel_setup), deferred :: setup
    procedure(cPairModel_compute), deferred :: compute
    procedure(cPairModel_mix), deferred :: mix
    procedure :: shifting_setup => cPairModel_shifting_setup
end type cPairModel

!> A class for no-interaction pair model:
type, extends(cPairModel) :: pair_none
  contains
    procedure :: setup => pair_none_setup
    procedure :: compute => pair_none_compute
    procedure :: mix => pair_none_mix
end type pair_none

!> A container structure for pair models:
type pairModelContainer
  class(cPairModel), allocatable :: model
  logical :: overridable
  contains
    procedure :: pairModelContainer_assign
    generic :: assignment(=) => pairModelContainer_assign
    procedure :: mix => pairModelContainer_mix
end type pairModelContainer

abstract interface

  subroutine cPairModel_setup( model, params )
    import
    class(cPairModel), intent(inout) :: model
    real(rb),          intent(in)    :: params(:)
  end subroutine cPairModel_setup

  subroutine cPairModel_compute( model, Eij, Wij, invR2, Qi, Qj )
    import
    class(cPairModel), intent(in)  :: model
    real(rb),          intent(out) :: Eij, Wij
    real(rb),          intent(in)  :: invR2, Qi, Qj
  end subroutine cPairModel_compute

  function cPairModel_mix( this, other ) result( mixed )
    import
    class(cPairModel), intent(in) :: this, other
    class(cPairModel), pointer    :: mixed
  end function cPairModel_mix

end interface

contains

!===================================================================================================
!                             P A I R     M O D E L    C L A S S
!===================================================================================================

  subroutine cPairModel_shifting_setup( model, cutoff )
    class(cPairModel), intent(inout) :: model
    real(rb),          intent(in)    :: cutoff

    real(rb) :: invR2, Evdw, Wvdw, Etot, Wtot, Ecoul, Wcoul

    ! Zero van der Waals and Coulombic energy and force shifts:
    model%fshift_vdw = zero
    model%eshift_vdw = zero
    model%fshift_coul = zero
    model%eshift_coul = zero

    ! Compute van der Waals and Coulombic energies and virials at cutoff:
    invR2 = one/cutoff**2
    call model%compute( Evdw, Wvdw, invR2, zero, zero )
    call model%compute( Etot, Wtot, invR2, one, one )
    Ecoul = Etot - Evdw
    Wcoul = Wtot - Wvdw

    ! Update van der Waals energy and force shifts:
    model%fshift_vdw = Wvdw/cutoff
    model%eshift_vdw = -Evdw
    if (model%shifted_force_vdw) model%eshift_vdw = model%eshift_vdw - Wvdw

    ! Update Coulombic energy and force shifts:
    model%fshift_coul = Wcoul/cutoff
    model%eshift_coul = -Ecoul
    if (model%shifted_force_coul) model%eshift_coul = model%eshift_coul - Wcoul

  end subroutine cPairModel_shifting_setup

!===================================================================================================
!                                   P A I R     N O N E
!===================================================================================================

  type(c_ptr) function EmDee_pair_none() bind(C,name="EmDee_pair_none")
    type(pair_none), pointer :: model
    allocate(model)
    call model% setup( [zero] )
    EmDee_pair_none = model % deliver()
  end function EmDee_pair_none

!---------------------------------------------------------------------------------------------------

  subroutine pair_none_setup( model, params )
    class(pair_none), intent(inout) :: model
    real(rb),         intent(in)    :: params(:)
  end subroutine pair_none_setup

!---------------------------------------------------------------------------------------------------

  subroutine pair_none_compute( model, Eij, Wij, invR2, Qi, Qj )
    class(pair_none), intent(in)  :: model
    real(rb),         intent(out) :: Eij, Wij
    real(rb),         intent(in)  :: invR2, Qi, Qj
    Eij = zero
    Wij = zero
  end subroutine pair_none_compute

!---------------------------------------------------------------------------------------------------

  function pair_none_mix( this, other ) result( mixed )
    class(pair_none),  intent(in) :: this
    class(cPairModel), intent(in) :: other
    class(cPairModel), pointer    :: mixed
    ! Mixing of all pair models with pair_none results in pair_none:
    allocate(pair_none :: mixed)
  end function pair_none_mix

!===================================================================================================
!                         P A I R     M O D E L    C O N T A I N E R
!===================================================================================================

  subroutine pairModelContainer_assign( new, old )
    class(pairModelContainer), intent(inout) :: new
    type(modelContainer), intent(in)    :: old

    if (allocated(new%model)) deallocate( new%model )

    if (allocated(old%model)) then
      select type (model => old%model)
        class is (cPairModel)
          allocate( new%model, source = model )
        class default
          stop "ERROR: cannot assign a pair model type from another model type"
      end select
    end if

  end subroutine pairModelContainer_assign

!---------------------------------------------------------------------------------------------------

  function pairModelContainer_mix( a, b ) result( c )
    class(pairModelContainer), intent(in) :: a
    class(cPairModel),         intent(in) :: b
    type(pairModelContainer)              :: c

    class(cPairModel), pointer :: mixed

    mixed => b % mix( a%model )
    if (.not.associated(mixed)) mixed => a % model % mix( b )
    if (associated(mixed)) then
      allocate( c%model, source = mixed )
      deallocate( mixed )
    else
      allocate( c%model, source = pair_none(kind="none") )
      write(*,'("WARNING: no mixing rule found for pair interaction models ",A," and ",A,".")') &
        trim(a % model % kind), trim(b % kind)
    end if
    c%overridable = .true.

  end function pairModelContainer_mix

!---------------------------------------------------------------------------------------------------

end module pairModelClass