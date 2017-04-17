# From hub.docker.com/r/microsoft/dotnet/, Note: The latest tag no longer uses the project.json project format, but has now been updated to be csproj/MSBuild-based. If you do not wish to migrate your existing projects to MSBuild simply change your Dockerfile to use the 1.1.0-sdk-projectjson or 1.1.0-sdk-projectjson-nanoserver tag. Going forward, new .NET Core sdk images will be MSBuild-based.
# The problem is that we need 1.1.1 runtime with 1.1.0 sdk...

FROM bwstitt/debian:jessie

# install deps
RUN docker-apt-install \
    ca-certificates \
    curl \
    libc6 \
    libcurl3 \
    libgcc1 \
    libgssapi-krb5-2 \
    libicu52 \
    liblttng-ust0 \
    libssl1.0.0 \
    libstdc++6 \
    libunwind8 \
    libuuid1 \
    zlib1g

# prepare a directory for fetching code
RUN mkdir /src && chown abc:abc /src

# install NET Core Runtime 1.1.1
ENV DOTNET_RUNTIME_SHA256 6359fcd443c686476c6b55bfcd5fdc214a64f8f399bfc1801e4d841c4ca163de
RUN curl -fSL -o dotnet.tar.gz "https://go.microsoft.com/fwlink/?LinkID=843423" \
 && echo "$DOTNET_RUNTIME_SHA256 dotnet.tar.gz" | sha256sum -c - \
 && mkdir -p /usr/share/dotnet \
 && tar -zxvf dotnet.tar.gz -C /usr/share/dotnet \
 && rm -rf dotnet.tar.gz

# install NET Core SDK 1.1.0 Preview 2.1
ENV DOTNET_SDK_SHA256 a2f228dc79501ee85ac5fcdf771886d8f84409bacfd3f9b3ba4225663cbfa3ef
RUN curl -fSL -o /dotnet.tar.gz "https://go.microsoft.com/fwlink/?LinkID=835021" \
 && echo "$DOTNET_SDK_SHA256 /dotnet.tar.gz" | sha256sum -c - \
 && mkdir -p /usr/share/dotnet \
 && tar -zxvf /dotnet.tar.gz -C /usr/share/dotnet \
 && rm -rf /dotnet.tar.gz \
 && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# copypasta from microsoft/dotnet
ENV NUGET_XMLDOC_MODE skip

# do everything after this as our application user
USER abc

# install the ntumblebit code
RUN curl -fSL https://github.com/NTumbleBit/NTumbleBit/archive/master.tar.gz | tar xvz -C /src/ \
 && cd /src/NTumbleBit-master \
 && dotnet restore \
 && rm -rf /tmp/NuGetScratch \
 && mkdir "$HOME/.ntumblebit" "$HOME/.ntumblebitserver"

# TODO: quick test to make sure the app works

VOLUME /home/abc/.ntumblebit /home/abc/.ntumblebitserver
