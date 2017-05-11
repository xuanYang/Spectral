/-
Copyright (c) 2016 Egbert Rijke. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Egbert Rijke, Steve Awodey

Exact couple, derived couples, and so on
-/

import algebra.group_theory hit.set_quotient types.sigma types.list types.sum .quotient_group .subgroup .ses

open eq algebra is_trunc set_quotient relation sigma sigma.ops prod prod.ops sum list trunc function group trunc
     equiv is_equiv

definition is_differential {B : AbGroup} (d : B →g B) := Π(b:B), d (d b) = 1

definition image_subgroup_of_diff {B : AbGroup} (d : B →g B) (H : is_differential d) : subgroup_rel (ab_kernel d) :=
  subgroup_rel_of_subgroup (image_subgroup d) (kernel_subgroup d)
  begin
    intro g p,
    induction p with f, induction f with h p,
    rewrite [p⁻¹],
    esimp,
    exact H h
  end

definition diff_im_in_ker {B : AbGroup} (d : B →g B) (H : is_differential d) : Π(b : B), image_subgroup d b → kernel_subgroup d b :=
  begin
    intro b p,
    induction p with q, induction q with b' p, induction p, exact H b'
  end

definition homology {B : AbGroup} (d : B →g B) (H : is_differential d) : AbGroup :=
  @quotient_ab_group (ab_kernel d) (image_subgroup_of_diff d H)

definition homology_ugly {B : AbGroup} (d : B →g B) (H : is_differential d) : AbGroup :=
  @quotient_ab_group (ab_kernel d) (image_subgroup (ab_subgroup_of_subgroup_incl (diff_im_in_ker d H)))

definition homology_iso_ugly {B : AbGroup} (d : B →g B) (H : is_differential d) : (homology d H) ≃g (homology_ugly d H) :=
  begin
  fapply @iso_of_ab_qg_group (ab_kernel d) (image_subgroup (ab_subgroup_of_subgroup_incl (diff_im_in_ker d H))) (image_subgroup_of_diff d H),

  end

definition SES_iso_C {A B C C' : AbGroup} (ses : SES A B C) (k : C ≃g C') : SES A B C' :=
  begin 
  fapply SES.mk,
  exact SES.f ses,
  exact k ∘g SES.g ses,
  exact SES.Hf ses,
  fapply @is_surjective_compose _ _ _ k (SES.g ses),
  exact is_surjective_of_is_equiv k,
  exact SES.Hg ses,
  fapply is_exact.mk,
  intro a,
  esimp,
  note h := SES.ex ses,
  note h2 := is_exact.im_in_ker h a,
  refine ap k h2 ⬝ _ ,
  exact to_respect_one k,
  intro b,
  intro k3,
  note h := SES.ex ses,
  note h3 := is_exact.ker_in_im h b,
  fapply is_exact.ker_in_im h,
  refine  _ ⬝ ap k⁻¹ᵍ k3 ⬝ _ ,
  esimp,
  exact (to_left_inv (equiv_of_isomorphism k) ((SES.g ses) b))⁻¹,
  exact to_respect_one k⁻¹ᵍ
  end

definition SES_of_differential_ugly {B : AbGroup} (d : B →g B) (H : is_differential d) : SES (ab_image d) (ab_kernel d) (homology_ugly d H) :=
  begin
    exact SES_of_inclusion (ab_subgroup_of_subgroup_incl (diff_im_in_ker d H)) (is_embedding_ab_subgroup_of_subgroup_incl (diff_im_in_ker d H)),
   end

definition SES_of_differential {B : AbGroup} (d : B →g B) (H : is_differential d) : SES (ab_image d) (ab_kernel d) (homology d H) :=
  begin
    exact SES_of_inclusion (ab_subgroup_of_subgroup_incl (diff_im_in_ker d H)) (is_embedding_ab_subgroup_of_subgroup_incl (diff_im_in_ker d H)),
    exact sorry,
   end

structure exact_couple (A B : AbGroup) : Type :=
  ( i : A →g A) (j : A →g B) (k : B →g A)
  ( exact_ij : is_exact i j)
  ( exact_jk : is_exact j k)
  ( exact_ki : is_exact k i)

definition differential {A B : AbGroup} (EC : exact_couple A B) : B →g B :=
  (exact_couple.j EC) ∘g (exact_couple.k EC)

definition differential_is_differential {A B : AbGroup} (EC : exact_couple A B) : is_differential (differential EC) :=
  begin
    induction EC,
    induction exact_jk,
    intro b,
    exact (ap (group_fun j) (im_in_ker (group_fun k b))) ⬝ (respect_one j)
  end

section derived_couple

  variables {A B : AbGroup} (EC : exact_couple A B)

definition derived_couple_A : AbGroup :=
  ab_subgroup (image_subgroup (exact_couple.i EC))

definition derived_couple_B : AbGroup :=
  homology (differential EC) (differential_is_differential EC)

definition derived_couple_i : derived_couple_A EC →g derived_couple_A EC :=
  (image_lift (exact_couple.i EC)) ∘g (image_incl (exact_couple.i EC))

definition derived_couple_j : derived_couple_A EC →g derived_couple_B EC :=
  begin
  exact sorry,
--    refine (comm_gq_map (comm_kernel (boundary CC)) (image_subgroup_of_bd (boundary CC) (boundary_is_boundary CC))) ∘g _,
  end

end derived_couple
