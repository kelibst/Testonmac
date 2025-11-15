# macOS VM GPU Acceleration Plan - RX 580 Utilization

## Current Situation Analysis

**Problem:** iOS Simulator is extremely slow because it's running entirely on CPU with NO GPU acceleration.

**Hardware Available:**
- AMD Radeon RX 580 (Polaris 20 XL)
- Driver: amdgpu (open-source kernel driver)
- DRI devices: `/dev/dri/card0` and `/dev/dri/renderD128`
- User groups: Missing `video` and `render` groups

**Current VM Graphics Config:**
```bash
-device qxl-vga,vgamem_mb=128,vram_size_mb=128
-display gtk,zoom-to-fit=off,gl=on
```
This is **pure software rendering** - QXL uses CPU, not your RX 580.

---

## Why macOS VM GPU Acceleration is Extremely Difficult

### The Fundamental Problem
macOS **ONLY** supports:
1. **Apple Metal** (proprietary, macOS-exclusive)
2. **Intel integrated graphics** (limited support)
3. **AMD GPUs** (only specific models with official macOS drivers)

### What macOS Does NOT Support
- ❌ VirtIO-GPU (Linux/Windows only)
- ❌ Vulkan (not available on macOS)
- ❌ DirectX (Windows only)
- ❌ Generic OpenGL passthrough from QEMU

### The macOS Catch-22
- macOS needs **native drivers** for GPU hardware
- AMD RX 580 **IS** supported by macOS natively
- But in a VM, macOS cannot see your physical RX 580
- QEMU cannot pass through AMD GPU to macOS like it can to Linux/Windows

---

## Available GPU Acceleration Approaches

### Option 1: GPU Passthrough (PCI Passthrough) ⚠️ COMPLEX
**What it does:** Give the VM exclusive access to your RX 580

**Requirements:**
- IOMMU enabled in BIOS
- GPU must be in its own IOMMU group
- Cannot use RX 580 on Linux host while VM is running
- Requires VFIO drivers
- Need second GPU for Linux host OR run headless

**Pros:**
- Near-native GPU performance
- macOS sees real AMD GPU
- Metal acceleration works

**Cons:**
- **You lose your Linux desktop while VM runs** (screen goes black)
- Complex VFIO setup
- Need second GPU or SSH-only access to Linux
- Can break if IOMMU groups are wrong

**Viability:** ⚠️ Possible but impractical (you need your Linux desktop)

---

### Option 2: VirtIO-GPU with Virgil3D 🔴 INCOMPATIBLE
**What it does:** Software-accelerated 3D using virglrenderer

**Status:** ❌ **Does NOT work with macOS**
- macOS has no VirtIO-GPU drivers
- Requires Linux guest or Windows with special drivers
- Already tested and failed in previous attempts

---

### Option 3: GPU Mediated Passthrough (GVT-g/SR-IOV) 🔴 AMD NOT SUPPORTED
**What it does:** Share GPU between host and VM

**Status:** ❌ **Only Intel iGPUs support GVT-g**
- AMD does not support SR-IOV on RX 580
- Your CPU (Xeon E5-2670 v3) has no integrated graphics

---

### Option 4: Looking Glass (Host GPU Rendering) ✅ MOST PROMISING
**What it does:**
- VM renders using CPU/software
- Looking Glass captures framebuffer
- Host GPU accelerates the display

**How it works:**
1. macOS VM uses QXL (software rendering)
2. Looking Glass captures VM display via shared memory
3. Your RX 580 accelerates display on Linux side
4. You get smooth 60fps display even if VM renders slowly

**Pros:**
- Don't lose Linux desktop
- Your RX 580 accelerates the **display**
- Smooth window movement and updates
- Can use SPICE or VNC alongside

**Cons:**
- VM still renders on CPU (but display is smooth)
- Complex setup (requires compiling Looking Glass)
- Shared memory configuration needed
- macOS Metal/OpenGL still not accelerated

**Viability:** ✅ **Best option for usability**

---

### Option 5: Optimize Software Rendering 🟡 REALISTIC COMPROMISE
**What it does:** Make CPU rendering as fast as possible

**Optimizations:**
1. **Add user to video/render groups** (access to DRM)
2. **Use virtio-vga with gl=on** (uses host OpenGL for display)
3. **Enable DRM render node** for GTK display
4. **Increase vgamem and vram** allocation
5. **Use SDL display** instead of GTK (better performance)
6. **CPU pinning** to reduce context switching

**Expected improvement:** 50-100% faster display (still not GPU-accelerated)

**Viability:** ✅ **Easiest to implement, moderate improvement**

---

## Recommended Plan: 3-Phase Approach

### Phase 1: Software Rendering Optimization (30 min - IMMEDIATE)

**Goal:** Make current setup 50-100% faster without GPU passthrough

**Steps:**

1. **Add user to video/render groups**
   ```bash
   sudo usermod -a -G video kelib
   sudo usermod -a -G render kelib
   # Logout and login required
   ```

2. **Update VM graphics config**
   ```bash
   # Replace QXL with virtio-vga-gl
   -device virtio-vga-gl,max_outputs=1,xres=1920,yres=1080
   -display gtk,gl=on,zoom-to-fit=off

   # Enable DRM render node
   -object rng-random,id=rng0,filename=/dev/urandom
   -device virtio-rng-pci,rng=rng0
   ```

3. **Enable 3D acceleration in GTK**
   ```bash
   -display gtk,gl=on,show-cursor=on
   ```

4. **CPU pinning for better performance**
   ```bash
   # Pin vCPUs to physical cores
   -smp 8,cores=8,threads=1,sockets=1
   # Add taskset wrapper in script
   taskset -c 0-7 qemu-system-x86_64 ...
   ```

**Expected Result:**
- Display responsiveness: +50-100%
- iOS Simulator: Still slow but more usable
- **VM still renders on CPU** (macOS limitation)

---

### Phase 2: Looking Glass Setup (2-3 hours - WEEKEND PROJECT)

**Goal:** Use RX 580 to accelerate VM display without passthrough

**Steps:**

1. **Install dependencies**
   ```bash
   sudo apt install build-essential cmake libgl1-mesa-dev \
     libfontconfig1-dev libspice-protocol-dev nettle-dev \
     wayland-protocols libxi-dev libxinerama-dev \
     libxcursor-dev libxpresent-dev libxss-dev
   ```

2. **Compile Looking Glass client**
   ```bash
   git clone https://github.com/gnif/LookingGlass.git
   cd LookingGlass
   mkdir client/build && cd client/build
   cmake ../
   make
   ```

3. **Configure VM for Looking Glass**
   ```bash
   # Add IVSHMEM device (shared memory)
   -device ivshmem-plain,memdev=ivshmem,bus=pcie.0
   -object memory-backend-file,id=ivshmem,share=on,mem-path=/dev/shm/looking-glass,size=128M

   # Add SPICE with QXL
   -device qxl-vga,vgamem_mb=256,ram_size_mb=256,vram_size_mb=256
   -spice port=5900,disable-ticketing=on
   -device virtio-serial-pci
   -chardev spicevmc,id=vdagent,name=vdagent
   -device virtserialport,chardev=vdagent,name=com.redhat.spice.0
   ```

4. **Run Looking Glass client on Linux**
   ```bash
   ./looking-glass-client -F
   ```

**Expected Result:**
- Buttery smooth display (60fps+)
- Your RX 580 handles all display rendering
- macOS VM still slow internally, but **looks fast**
- Can resize window smoothly

---

### Phase 3: Full GPU Passthrough (NUCLEAR OPTION - 4+ hours)

**Goal:** Give macOS exclusive access to RX 580

⚠️ **WARNING:** You will lose your Linux desktop while VM runs

**Prerequisites:**
- Second GPU for Linux OR SSH-only access
- IOMMU enabled in BIOS
- RX 580 in isolated IOMMU group

**Steps:**

1. **Enable IOMMU**
   ```bash
   # Edit /etc/default/grub
   GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on iommu=pt"
   # Update grub
   sudo update-grub
   reboot
   ```

2. **Bind RX 580 to VFIO**
   ```bash
   # Get GPU IDs
   lspci -nn | grep -i vga
   # Output: 03:00.0 VGA ... [1002:67df]

   # Blacklist amdgpu
   echo "options vfio-pci ids=1002:67df,1002:aaf0" > /etc/modprobe.d/vfio.conf
   echo "softdep amdgpu pre: vfio-pci" >> /etc/modprobe.d/vfio.conf
   update-initramfs -u
   reboot
   ```

3. **Pass GPU to macOS VM**
   ```bash
   -device vfio-pci,host=03:00.0,multifunction=on
   -device vfio-pci,host=03:00.1  # Audio function
   ```

4. **macOS will detect AMD GPU**
   - Metal acceleration works
   - Full GPU power available
   - Near-native performance

**Expected Result:**
- macOS runs at **near-native speed**
- iOS Simulator is fast
- **BUT:** Linux desktop is unusable (no GPU)

---

## My Recommendation: Phase 1 + Phase 2

### Implement Phase 1 Today (30 min)
- Add user to video/render groups
- Switch to virtio-vga-gl
- Enable DRM render node
- CPU pinning

**Improvement:** 50-100% display performance boost

### Implement Phase 2 This Weekend (2-3 hours)
- Set up Looking Glass
- Your RX 580 accelerates display
- Smooth 60fps experience

**Improvement:** 300-500% perceived performance

### Skip Phase 3 (Unless desperate)
- Too disruptive (lose Linux desktop)
- Complex setup
- Not worth it for testing

---

## Realistic Performance Expectations

### Current (QXL Software):
- Display: 15-20 fps
- Laggy mouse movement
- Slow window updates
- iOS Simulator: Painful

### After Phase 1 (virtio-vga-gl):
- Display: 25-35 fps
- Smoother mouse
- Better window updates
- iOS Simulator: Still slow but tolerable

### After Phase 2 (Looking Glass):
- Display: 60+ fps (silky smooth)
- Perfect mouse/keyboard
- Instant window updates
- iOS Simulator: **Still slow internally** but looks smooth

### After Phase 3 (GPU Passthrough):
- Everything: Near-native speed
- iOS Simulator: Fast
- **Cost:** No Linux desktop

---

## Bottom Line

**For iOS development/testing, Phase 1 + Phase 2 is the sweet spot.**

You get:
- ✅ Keep your Linux desktop
- ✅ RX 580 accelerates the display
- ✅ Smooth visual experience
- ✅ Practical for daily use

You accept:
- ⚠️ macOS still renders on CPU (Apple's fault, not yours)
- ⚠️ iOS Simulator won't be as fast as real Mac
- ⚠️ Some operations will be slow (Xcode builds, etc.)

**The iOS Simulator will NEVER be as fast as a real Mac in a VM** because:
1. macOS only understands Apple's Metal API
2. Can't translate Metal to QEMU's virtualized GPU
3. iOS Simulator is already a CPU-heavy process

But with Looking Glass, it will **feel** much smoother.

---

## Next Steps

1. **Try Phase 1 now?** (30 min, reversible)
2. **Plan Phase 2 for weekend?** (2-3 hours)
3. **Accept slower Simulator as trade-off?**

What would you like to do?
