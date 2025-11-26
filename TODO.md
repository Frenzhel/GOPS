# TODO for Bulk Counting Flipped Pogs

- [x] Modify scripts/pog.gd: Remove flip_decided signal emission and queue_free call
- [x] Modify scripts/pog_stack.gd: Remove signal connection code in spawn_stack
- [x] Modify scripts/main.gd: Remove _on_pog_flipped function and flip_count increment logic; update _on_flip_timer_timeout to bulk count flipped pogs and queue_free them
- [x] Update TODO.md to reflect bulk counting change
- [ ] Test the game to verify bulk scoring works correctly
