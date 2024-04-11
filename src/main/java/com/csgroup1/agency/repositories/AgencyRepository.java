package com.csgroup1.agency.repositories;

import com.csgroup1.agency.models.Agency;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AgencyRepository extends JpaRepository<Agency, Long> {
}
