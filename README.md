# Émulateur Mini-RISC

Un émulateur RISC-V RV32I simple écrit en C pour l'apprentissage et le développement de logiciels embarqués.

## 📋 Description

Ce projet implémente un émulateur de processeur RISC-V 32 bits (RV32I) capable d'exécuter des programmes en langage assembleur RISC-V compilés. L'émulateur simule la mémoire, les registres et l'exécution des instructions de base de l'architecture RISC-V.

## 🎯 Fonctionnalités

- **Architecture RV32I** : Support du jeu d'instructions RISC-V de base 32 bits
- **Mémoire simulée** : 64 Ko de mémoire RAM
- **32 registres** : Registres x0-x31 conformes à la spécification RISC-V
- **Chargement de binaires** : Charge des fichiers binaires ELF ou raw
- **Débogage** : Affichage de l'état des registres et du nombre d'instructions exécutées

## 🛠️ Prérequis

- GCC (compilateur C)
- Make
- Toolchain RISC-V : `gcc-riscv64-unknown-elf`
- Système d'exploitation : Linux (testé sur Ubuntu/WSL)

### Installation de la toolchain RISC-V

```bash
# Mise à jour du système
sudo apt update

# Installation des outils de build
sudo apt install build-essential

# Installation du compilateur RISC-V
sudo apt install gcc-riscv64-unknown-elf
```

![Installation de la toolchain](screenshots/installation.png)

## 📦 Structure du projet

```
projet-mini-risc/
├── emulator/              # Code source de l'émulateur
│   ├── main.c            # Point d'entrée principal
│   ├── minirisc.c        # Logique de l'émulateur
│   ├── minirisc.h        # Définitions et prototypes
│   ├── platform.c        # Fonctions plateforme
│   ├── platform.h        # En-têtes plateforme
│   ├── Makefile          # Compilation de l'émulateur
│   └── build/            # Binaires compilés
│
└── embedded_software/     # Programmes de test
    ├── arithmetic/       # Tests arithmétiques
    ├── branch/           # Tests de branchement
    ├── fibonacci/        # Suite de Fibonacci
    ├── hello_world/      # Hello World
    ├── logic/            # Opérations logiques
    └── memory/           # Opérations mémoire
```

## 🚀 Compilation

### Compiler l'émulateur

```bash
cd emulator
make clean
make
```

L'exécutable `emulator` sera créé dans le dossier `build/`.

![Compilation de l'émulateur](screenshots/emulator_build.png)

### Compiler un programme de test

```bash
cd embedded_software/hello_world
make clean
make
```

Le binaire `esw.bin` sera généré dans le dossier `build/`.

## ▶️ Utilisation

### Exécuter un programme

```bash
cd emulator
./build/emulator ../embedded_software/hello_world/build/esw.bin
```

### Exemples de programmes disponibles

#### 1. Hello World
```bash
./build/emulator ../embedded_software/hello_world/build/esw.bin
```
Affiche : `Hello, Mini-RISC World!`

![Hello World](screenshots/hello_world.png)

#### 2. Tests arithmétiques
```bash
./build/emulator ../embedded_software/arithmetic/build/esw.bin
```
Teste les opérations : addition, soustraction, multiplication, division, modulo

![Tests arithmétiques](screenshots/arithmetic.png)

#### 3. Suite de Fibonacci
```bash
./build/emulator ../embedded_software/fibonacci/build/esw.bin
```
Calcule les premiers nombres de Fibonacci

![Suite de Fibonacci](screenshots/fibonacci.png)

#### 4. Tests de branchement
```bash
./build/emulator ../embedded_software/branch/build/esw.bin
```
Teste les instructions de saut conditionnel et boucles

![Tests de branchement](screenshots/branch.png)

#### 5. Opérations logiques
```bash
./build/emulator ../embedded_software/logic/build/esw.bin
```
Teste AND, OR, XOR, shifts et opérations bit à bit

![Opérations logiques](screenshots/logic.png)

#### 6. Opérations mémoire
```bash
./build/emulator ../embedded_software/memory/build/esw.bin
```
Teste les accès mémoire (byte, half-word, word)

![Opérations mémoire](screenshots/memory.png)

## 📝 Développement de nouveaux programmes

### Structure d'un programme minimal

```c
// hello_world.S
.section .text
.globl _start

_start:
    # Votre code ici
    
    # Terminer le programme
    li a7, 93        # Syscall exit
    li a0, 0         # Code retour
    ecall
```

### Makefile type

```makefile
CROSS_COMPILE = riscv64-unknown-elf-
CC = $(CROSS_COMPILE)gcc
OBJCOPY = $(CROSS_COMPILE)objcopy

CFLAGS = -march=rv32im -mabi=ilp32 -W -Wall -O2 -x assembler-with-cpp
LDFLAGS = -march=rv32im -mabi=ilp32 -nostdlib -nostartfiles -Wl,-Ttext=0x80000000

all: build/esw.bin

build/%.o: %.S
	@mkdir -p build
	$(CC) $(CFLAGS) -c $< -o $@ -MMD -MP -MF"$(@:%.o=%.d)"

build/esw.elf: build/votre_programme.o
	$(CC) $(LDFLAGS) -o $@ $^ -T linker.ld

build/esw.bin: build/esw.elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -rf build
```

## 🔧 Détails techniques

### Registres RISC-V

| Registre | Nom ABI | Description |
|----------|---------|-------------|
| x0 | zero | Toujours zéro |
| x1 | ra | Adresse de retour |
| x2 | sp | Pointeur de pile |
| x3 | gp | Pointeur global |
| x4 | tp | Pointeur thread |
| x5-x7 | t0-t2 | Temporaires |
| x8-x9 | s0-s1 | Sauvegardés |
| x10-x17 | a0-a7 | Arguments/retours |
| x18-x27 | s2-s11 | Sauvegardés |
| x28-x31 | t3-t6 | Temporaires |

### Instructions supportées

- **Arithmétiques** : ADD, SUB, ADDI
- **Logiques** : AND, OR, XOR, SLL, SRL, SRA
- **Mémoire** : LB, LH, LW, SB, SH, SW
- **Branchements** : BEQ, BNE, BLT, BGE, BLTU, BGEU
- **Sauts** : JAL, JALR
- **Système** : ECALL

### Organisation mémoire

```
0x80000000  ┌─────────────┐
            │    .text    │  Code du programme
            ├─────────────┤
            │    .data    │  Données initialisées
            ├─────────────┤
            │    .bss     │  Données non initialisées
            ├─────────────┤
            │   Stack     │  Pile (croît vers le bas)
0x8000FFFF  └─────────────┘
```

## 🐛 Débogage

L'émulateur affiche automatiquement :
- Le nombre d'octets chargés
- L'adresse de chargement
- Le nombre d'instructions exécutées

Pour ajouter plus de traces, modifier `minirisc.c` :

```c
// Afficher les registres
void print_registers(CPU *cpu) {
    for (int i = 0; i < 32; i++) {
        printf("x%d = 0x%08x\n", i, cpu->regs[i]);
    }
}
```

## 📚 Ressources

- [Spécification RISC-V](https://riscv.org/technical/specifications/)
- [RISC-V Assembly Programmer's Manual](https://github.com/riscv-non-isa/riscv-asm-manual)
- [RISC-V Green Card](https://www.cl.cam.ac.uk/teaching/1617/ECAD+Arch/files/docs/RISCVGreenCardv8-20151013.pdf)

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Signaler des bugs
- Proposer de nouvelles fonctionnalités
- Soumettre des pull requests
- Ajouter de nouveaux programmes de test

## 📄 Licence

Ce projet est fourni à des fins éducatives.

## ✨ Auteur

Développé dans le cadre de l'apprentissage de l'architecture RISC-V et du développement de logiciels embarqués.

---

**Note** : Ce projet utilise WSL (Windows Subsystem for Linux) pour le développement. Les chemins incluent `/mnt/c/` qui correspondent au système de fichiers Windows monté dans WSL.