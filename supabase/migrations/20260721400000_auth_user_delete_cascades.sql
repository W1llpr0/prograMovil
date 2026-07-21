-- User-owned audit/content rows must not make an Auth account impossible to
-- delete. Their parent consultation/pet is deleted with the account as well.

alter table public.consultation_documents
  drop constraint if exists consultation_documents_uploaded_by_fkey,
  add constraint consultation_documents_uploaded_by_fkey
    foreign key (uploaded_by) references auth.users(id) on delete cascade;

alter table public.treatment_adherence
  drop constraint if exists treatment_adherence_created_by_fkey,
  add constraint treatment_adherence_created_by_fkey
    foreign key (created_by) references auth.users(id) on delete cascade;

alter table public.legal_documents
  drop constraint if exists legal_documents_uploaded_by_fkey,
  add constraint legal_documents_uploaded_by_fkey
    foreign key (uploaded_by) references auth.users(id) on delete cascade;
