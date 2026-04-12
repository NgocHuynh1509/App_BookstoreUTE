package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.Presence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface PresenceRepository extends JpaRepository<Presence, String> {


}