# Architecture

![TempFileLink Architecture](https://github.com/user-attachments/assets/ff5d94a8-ceed-4d7e-9c03-c49b5681ae8c)

We implement architecture that:

- **Secure** by leveraging AWS certificate manager for our domain.
- Achieve **High Availability** by deploying resources across multiple Availability Zones.
- **High Elasticity** by scaling automatically to ensure that resources can adapt to changes in traffic demands.
- Ensure **fault tolerance** with an ALB to distribute traffic and ASG automatic self-healing.
- **Cloud-native** by using and integrating AWS services.
