typedef enum {
  NONE,
  LJ,
  SHIFTED_FORCE_LJ
} tModel;

typedef struct {
  tModel model;
  double p1;
  double p2;
  double p3;
  double p4;
} tPairType;

typedef struct {
  double Eij;
  double Wij;
} tModelOutput;

#define nbcells 58

typedef struct {
  int neighbor[nbcells];
} tCell;

typedef struct {
  int builds;        // Number of neighbor-list builds
  int *first;        // First neighbor of each atom
  int *last;         // Last neighbor of each atom 
  int *neighbor;     // List of neighbors

  double time, checktime; // APAGAR DEPOIS DE TESTAR

  int natoms;        // Number of atoms
  int nx3;           // Three times the number of atoms
  int npairs;        // Number of neighbor pairs
  int maxpairs;      // Maximum number of neighbor pairs
  int mcells;        // Number of cells at each dimension
  int ncells;        // Total number of cells
  int maxcells;      // Maximum number of cells

  double Rc;         // Cut-off distance
  double xRc;        // Extended cutoff distance (including skin)
  double xRcSq;      // Extended cutoff distance squared
  double skinSq;     // Square of the neighbor list skin width

  tCell *cell;
  int *next;         // Next atom in a linked list of atoms

  int *type;         // Atom types
  double *R0;        // Atom positions at list building
  double *R;         // Pointer to dynamic atom positions
  double *P;         // Pointer to dynamic atom momenta
  double *F;

  int ntypes;
  tPairType *pairType;

  double Energy;
  double Virial;
} tEmDee;

static const int nb[nbcells][3] = { { 0, 0,-1}, { 0,-1, 0}, {-1, 0, 0}, { 0,-1,-1}, {-1, 0,-1},
                                    { 0, 1,-1}, { 1, 0,-1}, { 1,-1, 0}, {-1,-1, 0}, {-1,-1,-1},
                                    {-1, 1,-1}, { 1, 1,-1}, { 1,-1,-1}, { 0, 0,-2}, { 0,-2, 0},
                                    {-2, 0, 0}, { 1, 0,-2}, { 2,-1, 0}, { 0, 2,-1}, { 0,-1,-2},
                                    {-1, 0,-2}, { 0, 1,-2}, { 0,-2,-1}, {-2, 0,-1}, { 2, 0,-1},
                                    {-1,-2, 0}, { 1,-2, 0}, {-2,-1, 0}, {-1,-1,-2}, {-1, 1,-2},
                                    { 1, 1,-2}, {-1,-2,-1}, { 1,-2,-1}, {-2,-1,-1}, { 2,-1,-1},
                                    { 1,-1,-2}, {-2, 1,-1}, { 2, 1,-1}, { 1, 2,-1}, {-1, 2,-1},
                                    { 0,-2,-2}, {-2, 0,-2}, {-2,-2, 0}, { 2,-2, 0}, { 0, 2,-2},
                                    {-1,-2,-2}, { 1,-2,-2}, {-2,-1,-2}, { 2,-1,-2}, { 2, 0,-2},
                                    {-2, 1,-2}, { 2, 1,-2}, {-1, 2,-2}, { 1, 2,-2}, {-2,-2,-1},
                                    { 2,-2,-1}, {-2, 2,-1}, { 2, 2,-1} };

void md_initialize( tEmDee *me, double rc, double skin, int atoms, int *types );
void md_set_lj( tEmDee *me, int i, int j, double sigma, double epsilon );
void md_set_shifted_force_lj( tEmDee *me, int i, int j, double sigma, double epsilon );
void md_upload( tEmDee *me, double *coords, double *momenta );
void md_download( tEmDee *me, double *coords, double *momenta, double *forces );
void md_change_coordinates( tEmDee *me, double a, double b );
void md_change_momenta( tEmDee *me, double a, double b );
void md_compute_forces( tEmDee *me, double L );

