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

! INPUT:  invR2, Qi, Qj, model
! OUTPUT: Eij, Wij

block
  real(rb) :: rsig2, rsig6, sinv, sinvSq, sinvCb, rFc, invR, QiQj, QiQjbyR
  rsig2 = model%invSigSq/invR2
  rsig6 = rsig2*rsig2*rsig2
  sinv = one/(rsig6 + model%shift)
  sinvSq = sinv*sinv
  sinvCb = sinv*sinvSq
  invR = sqrt(invR2)
  QiQj = Qi*Qj
  QiQjbyR = QiQj*invR
  rFc = (model%fshift_vdw + QiQj*model%fshift_coul)/invR
  Eij = model%prefactor*(sinvSq - sinv) + QiQjbyR + model%eshift_vdw + QiQj*model%eshift_coul + rFc
  Wij = model%prefactor6*rsig6*(sinvCb + sinvCb - sinvSq) + QiQjbyR - rFc
end block

