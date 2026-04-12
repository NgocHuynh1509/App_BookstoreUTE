package com.hcmute.bookstore.Repository;

import com.hcmute.bookstore.Entity.PointTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface PointTransactionRepository extends JpaRepository<PointTransaction, String> {


}