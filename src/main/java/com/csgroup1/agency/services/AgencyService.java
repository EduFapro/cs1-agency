package com.csgroup1.agency.services;

import com.csgroup1.agency.models.Agency;
import com.csgroup1.agency.repositories.AgencyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AgencyService {

    private final AgencyRepository agencyRepository;

    @Autowired
    public AgencyService(AgencyRepository agencyRepository) {
        this.agencyRepository = agencyRepository;
    }

    public List<Agency> getAllAgencies() {
        return agencyRepository.findAll();
    }

    public Optional<Agency> getAgencyById(Long id) {
        return agencyRepository.findById(id);
    }

    public Agency createAgency(Agency agency) {
        return agencyRepository.save(agency);
    }

    public Agency updateAgency(Long id, Agency agencyDetails) {
        Agency agency = agencyRepository.findById(id).orElseThrow(() -> new RuntimeException("Agency not found"));
        agency.setName(agencyDetails.getName());
        agency.setAddress(agencyDetails.getAddress());
        agency.setPhoneNumber(agencyDetails.getPhoneNumber());
        agency.setEmail(agencyDetails.getEmail());
        agency.setLogo(agencyDetails.getLogo());
        agency.setCnpj(agencyDetails.getCnpj());
        return agencyRepository.save(agency);
    }

    public void deleteAgency(Long id) {
        agencyRepository.deleteById(id);
    }
}
