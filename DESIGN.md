# chronos design

## Data

Backtests are made on OHLCV bars, with different granularities, up to per-tick bars.

Time is represented as a timestamp (nanoseconds since epoch in UTC) so that we avoid confusion with timezones. The conversion (the session you want to replay on) is made at the beginning of the backtest to select the correct period of time to run the backtest on.

Prices are represented as fixed-point integers. Exactness and determinism are the key and we want to make sure that each backtest is reproducible.

The data is stored as SoA to enable simd arithmetic when possible. The JIT engine maps your strategy to find optimization opportunities and runs the computations in parallel when possible.

```python
@main(symbol=NVDA) # We are trading (executing orders on) Nvidia
def strategy(NVDA, VIX):
    if VIX.close[-1] > 30 and NVDA.high[-1] > 200:
        return Position.Short if position.anyOpen() else None
    elif VIX.close[-1] < 30:
        return Position.Long
    else:
        return None
```

The downloaded data (as CSV usually) is loaded on demand (depending on your strategy), converted into chronos format, and mapped in memory, or streamed in chunks from disk if your computer does not have enough memory to store everything in RAM.
