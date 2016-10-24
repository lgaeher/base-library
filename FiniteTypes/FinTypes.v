Require Export BasicDefinitions.
(** ** Formalisation of finite types using canonical structures and type classes *)

(** * Definition of finite Types *)

Class finTypeC  (type:eqType) : Type := FinTypeC {
                                            enum: list type;
                                            enum_ok: forall x: type, count enum x = 1
                                          }.

Structure finType : Type := FinType {
                                type:> eqType;
                                class: finTypeC type }.

Arguments FinType type {class}.
Existing Instance class | 0.

Canonical Structure finType_CS (X : Type) {p : eq_dec X} {class : finTypeC (EqType X)} : finType := FinType (EqType X).

Definition elem (F: finType) := @enum (type F) (class F).
Hint Unfold elem.
Hint Unfold class.

Lemma elem_spec (X: finType) (x:X) : x el (elem X).
Proof.
  apply countIn.  pose proof (enum_ok x) as H. unfold elem. omega.
Qed.

Hint Resolve elem_spec.
Hint Resolve enum_ok.

Lemma allSub (X: finType) (A:list X) : A <<= elem X.
Proof.
  intros x _. apply elem_spec.
Qed.
Arguments allSub {X} A a {_}.
Hint Resolve allSub.

(** A properties that hold on every element of (elem X) hold for every element of the finType X *)
Theorem Equivalence_property_all (X: finType) (p: X -> Prop) :
  (forall x, p x) <-> forall x, x el (elem X) -> p x.
Proof.
  split; auto. 
Qed.

Theorem Equivalence_property_exists (X: finType) (p:X -> Prop):
  (exists x, p x) <-> exists x, x el (elem X) /\ p x.
Proof.
  split.
  - intros [x P]. eauto.
  - intros [x [E P]]. eauto.
Qed.

Instance finType_forall_dec (X: finType) (p: X -> Prop): (forall x, dec (p x)) -> dec (forall x, p x).
Proof.
  intros D. eapply dec_transfer.
  - symmetry. exact (Equivalence_property_all p).
  - auto.
Qed.

Instance finType_exists_dec (X:finType) (p: X -> Prop) : (forall x, dec (p x)) -> dec (exists x, p x).
Proof.
  intros D. eapply dec_transfer.
  - symmetry. exact (Equivalence_property_exists p).
  - auto.
Qed.

Definition finType_cc (X: finType) (p: X -> Prop) (D: forall x, dec (p x)) : (exists x, p x) -> {x | p x}.
Proof.
  intro H.
  assert(exists x, x el (elem X) /\ p x) as E by firstorder.
  pose proof (list_cc D E) as [x G].
  now exists x.
Defined.

Definition pickx (X: finType): X + (X -> False).
Proof.
  destruct X as [X [enum ok]]. induction enum.
  - right. intro x. discriminate (ok x).
  - tauto.
Defined.

(** * Properties of decidable Propositions *)

Lemma DM_notAll (X: finType) (p: X -> Prop) (D:forall x, dec (p x)): (~ (forall x, p x)) <-> exists x, ~ (p x).
Proof.     
  decide (exists x,~ p x); firstorder.
Qed.

Lemma DM_exists (X: finType) (p: X -> Prop) (D: forall x, dec (p x)):
  (exists x, p x) <->  ~(forall x, ~ p x).
Proof.
  split.
  - firstorder.
  - decide (exists x, p x); firstorder.
Qed.

(* Index is an injective function *)


Fixpoint  getPosition {E: eqType} (A: list E) x := match A with
                                                   | nil => 0
                                                   | cons x' A' => if Dec (x=x') then 0 else 1 + getPosition A' x end.

Lemma getPosition_correct {E: eqType} (x:E) A: if Dec (x el A) then forall z, (nth (getPosition A x) A z) = x else getPosition A x = |A |.
Proof.
  induction A;cbn.
  -repeat destruct Dec;tauto.
  -repeat destruct Dec;intuition; congruence.
Qed.

Definition pos_def (X : eqType) (x : X) A n :=  match pos x A with None => n | Some n => n end. 

Definition index {F: finType} (x:F) := getPosition (elem F) x.

Lemma index_nth {F : finType} (x:F) y: nth (index x) (elem F) y = x.
  unfold index, elem, enum.
  destruct F as [[X E] [A all_A]];cbn.
  assert (H := getPosition_correct x A).
  destruct Dec. auto. apply notInZero in n. now setoid_rewrite all_A in n.
Qed.
 