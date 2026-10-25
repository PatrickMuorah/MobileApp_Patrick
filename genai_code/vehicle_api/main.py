"""
main.py - In-memory CRUD API for vehicle manufacturers and their vehicles.

Run with:
    pip install fastapi uvicorn pydantic
    uvicorn main:app --reload
"""

from typing import Dict, List

from fastapi import FastAPI, HTTPException, Response, status
from pydantic import BaseModel, Field

app = FastAPI(title="Vehicle API", version="1.0.0")


# ---------------------------------------------------------------------------
# Pydantic models
# ---------------------------------------------------------------------------

class ManufacturerBase(BaseModel):
    """Fields a client supplies when creating/updating a manufacturer."""
    name: str = Field(..., min_length=1, description="Manufacturer name")
    country: str = Field(..., min_length=1, description="Country of origin")


class Manufacturer(ManufacturerBase):
    """Manufacturer as stored and returned by the API."""
    id: int


class VehicleBase(BaseModel):
    """Fields a client supplies when creating/updating a vehicle."""
    manufacturer_id: int = Field(..., description="ID of the owning manufacturer")
    model: str = Field(..., min_length=1, description="Vehicle model name")
    year: int = Field(..., ge=1886, le=2100, description="Model year")
    price: float = Field(..., ge=0, description="Price in USD")


class Vehicle(VehicleBase):
    """Vehicle as stored and returned by the API."""
    id: int


# ---------------------------------------------------------------------------
# In-memory storage and ID counters
# ---------------------------------------------------------------------------

manufacturers: Dict[int, Manufacturer] = {}
vehicles: Dict[int, Vehicle] = {}

_next_manufacturer_id: int = 1
_next_vehicle_id: int = 1


def _new_manufacturer_id() -> int:
    """Return the next auto-increment manufacturer ID."""
    global _next_manufacturer_id
    new_id = _next_manufacturer_id
    _next_manufacturer_id += 1
    return new_id


def _new_vehicle_id() -> int:
    """Return the next auto-increment vehicle ID."""
    global _next_vehicle_id
    new_id = _next_vehicle_id
    _next_vehicle_id += 1
    return new_id


def _seed_data() -> None:
    """Populate 3 manufacturers and 6 vehicles at startup."""
    seed_manufacturers = [
        ManufacturerBase(name="Toyota", country="Japan"),
        ManufacturerBase(name="Ford", country="United States"),
        ManufacturerBase(name="Volkswagen", country="Germany"),
    ]
    for m in seed_manufacturers:
        new_id = _new_manufacturer_id()
        manufacturers[new_id] = Manufacturer(id=new_id, **m.model_dump())

    seed_vehicles = [
        VehicleBase(manufacturer_id=1, model="Corolla", year=2023, price=22050.00),
        VehicleBase(manufacturer_id=1, model="Camry", year=2024, price=28400.00),
        VehicleBase(manufacturer_id=2, model="F-150", year=2023, price=36770.00),
        VehicleBase(manufacturer_id=2, model="Mustang", year=2024, price=32515.00),
        VehicleBase(manufacturer_id=3, model="Golf", year=2022, price=24000.00),
        VehicleBase(manufacturer_id=3, model="Passat", year=2023, price=27995.00),
    ]
    for v in seed_vehicles:
        new_id = _new_vehicle_id()
        vehicles[new_id] = Vehicle(id=new_id, **v.model_dump())


_seed_data()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _get_manufacturer_or_404(manufacturer_id: int) -> Manufacturer:
    """Fetch a manufacturer or raise a 404."""
    manufacturer = manufacturers.get(manufacturer_id)
    if manufacturer is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Manufacturer with id {manufacturer_id} not found",
        )
    return manufacturer


def _get_vehicle_or_404(vehicle_id: int) -> Vehicle:
    """Fetch a vehicle or raise a 404."""
    vehicle = vehicles.get(vehicle_id)
    if vehicle is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Vehicle with id {vehicle_id} not found",
        )
    return vehicle


def _require_valid_manufacturer(manufacturer_id: int) -> None:
    """Raise a 400 if the given manufacturer_id does not exist."""
    if manufacturer_id not in manufacturers:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid manufacturer_id: manufacturer {manufacturer_id} does not exist",
        )


# ---------------------------------------------------------------------------
# Root
# ---------------------------------------------------------------------------

@app.get("/")
def root() -> Dict[str, str]:
    """Health-check style root endpoint."""
    return {"message": "Vehicle API is running"}


# ---------------------------------------------------------------------------
# Manufacturer endpoints
# ---------------------------------------------------------------------------

@app.get("/manufacturers", response_model=List[Manufacturer])
def list_manufacturers() -> List[Manufacturer]:
    """List all manufacturers."""
    return list(manufacturers.values())


@app.get("/manufacturers/{manufacturer_id}", response_model=Manufacturer)
def get_manufacturer(manufacturer_id: int) -> Manufacturer:
    """Get a single manufacturer by ID."""
    return _get_manufacturer_or_404(manufacturer_id)


@app.post(
    "/manufacturers",
    response_model=Manufacturer,
    status_code=status.HTTP_201_CREATED,
)
def create_manufacturer(payload: ManufacturerBase) -> Manufacturer:
    """Create a new manufacturer."""
    new_id = _new_manufacturer_id()
    manufacturer = Manufacturer(id=new_id, **payload.model_dump())
    manufacturers[new_id] = manufacturer
    return manufacturer


@app.put("/manufacturers/{manufacturer_id}", response_model=Manufacturer)
def update_manufacturer(manufacturer_id: int, payload: ManufacturerBase) -> Manufacturer:
    """Replace an existing manufacturer's fields."""
    _get_manufacturer_or_404(manufacturer_id)
    updated = Manufacturer(id=manufacturer_id, **payload.model_dump())
    manufacturers[manufacturer_id] = updated
    return updated


@app.delete("/manufacturers/{manufacturer_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_manufacturer(manufacturer_id: int) -> Response:
    """Delete a manufacturer by ID."""
    _get_manufacturer_or_404(manufacturer_id)
    del manufacturers[manufacturer_id]
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@app.get("/manufacturers/{manufacturer_id}/vehicles", response_model=List[Vehicle])
def list_manufacturer_vehicles(manufacturer_id: int) -> List[Vehicle]:
    """List all vehicles belonging to one manufacturer."""
    _get_manufacturer_or_404(manufacturer_id)
    return [v for v in vehicles.values() if v.manufacturer_id == manufacturer_id]


# ---------------------------------------------------------------------------
# Vehicle endpoints
# ---------------------------------------------------------------------------

@app.get("/vehicles", response_model=List[Vehicle])
def list_vehicles() -> List[Vehicle]:
    """List all vehicles."""
    return list(vehicles.values())


@app.get("/vehicles/{vehicle_id}", response_model=Vehicle)
def get_vehicle(vehicle_id: int) -> Vehicle:
    """Get a single vehicle by ID."""
    return _get_vehicle_or_404(vehicle_id)


@app.post(
    "/vehicles",
    response_model=Vehicle,
    status_code=status.HTTP_201_CREATED,
)
def create_vehicle(payload: VehicleBase) -> Vehicle:
    """Create a new vehicle (400 if manufacturer_id is invalid)."""
    _require_valid_manufacturer(payload.manufacturer_id)
    new_id = _new_vehicle_id()
    vehicle = Vehicle(id=new_id, **payload.model_dump())
    vehicles[new_id] = vehicle
    return vehicle


@app.put("/vehicles/{vehicle_id}", response_model=Vehicle)
def update_vehicle(vehicle_id: int, payload: VehicleBase) -> Vehicle:
    """Replace an existing vehicle's fields (404 if missing, 400 if manufacturer invalid)."""
    _get_vehicle_or_404(vehicle_id)
    _require_valid_manufacturer(payload.manufacturer_id)
    updated = Vehicle(id=vehicle_id, **payload.model_dump())
    vehicles[vehicle_id] = updated
    return updated


@app.delete("/vehicles/{vehicle_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_vehicle(vehicle_id: int) -> Response:
    """Delete a vehicle by ID."""
    _get_vehicle_or_404(vehicle_id)
    del vehicles[vehicle_id]
    return Response(status_code=status.HTTP_204_NO_CONTENT)