/*
 *   $Id$
 *
 *   Copyright 2008 Glencoe Software, Inc. All rights reserved.
 *   Use is subject to license terms supplied in LICENSE.txt
 *
 */

#ifndef OMERO_GATEWAY_ICE
#define OMERO_GATEWAY_ICE

#include <omero/API.ice>
#include <omero/ServerErrors.ice>

module omero {

    module api {

        // Data objects
        // =====================================================================

	/*
	 * Simple wrapper around an array of packed ints. Individual language
	 * mappings may want to add a subclass to the ObjectFactory for working
	 * with a visual representation of the ints.
	 */
        class BufferedImage
        {
            IntegerArray packedInts;
        };

        enum ContainerClass
        {
            Category,
            CategoryGroup,
            Project,
            Dataset,
            Image
        };

        // Gateway Service
        // =====================================================================

	/*
	 * High-level service which provides a single interface for most client
	 * activities. Each stateful Gateway instance internally manages multiple
	 * other stateful instances (RenderingEngine, ThumbnailStore, etc.) significantly
	 * simplyifing usage.
	 */
        ["ami"] interface Gateway extends StatefulServiceInterface
	{

            /*
             * Get the projects, and datasets in the OMERO.Blitz server in the user
             * account.
             * @param ids user ids to get the projects from, if null will retrieve all
             * projects from the users account.
             * @param withLeaves get the projects, images and pixels too.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent ProjectList getProjects(LongList ids, bool withLeaves)
                throws omero::ServerError;

            /*
             * Get the datasets in the OMERO.Blitz server in the projects ids.
             * @param ids of the datasets to retrieve, if null get all users datasets.
             * @param withLeaves get the images and pixels too.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent DatasetList getDatasets(LongList ids, bool withLeaves)
                throws omero::ServerError;


            /*
             * Get the dataset in the OMERO.Blitz server with the given id.
             * @param id of the dataset to retrieve
             * @param withLeaves get the images and pixels too.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent omero::model::Dataset getDataset(long datasetId, bool leaves)
                throws omero::ServerError;

            /*
             * Get the pixels associated with the image, this is normally one pixels per
             * image, but can be more.
             * @param imageId
             * @return the list of pixels.
             * @throws omero::ServerError
             */
            idempotent PixelsList getPixelsFromImage(long imageId)
                throws omero::ServerError;

            /*
             * Get the image with id
             * @param id see above
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent omero::model::Image getImage(long id)
                throws omero::ServerError;

            /*
             * Get the images in the OMERO.Blitz server from the object parentType with
             * id's in list ids.
             * @param parentType see above.
             * @param ids see above.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent ImageList getImages(ContainerClass parentType, LongList ids )
                throws omero::ServerError;

            /*
             * Run the query passed as a string in the iQuery interface. This method will
             * return list of objects.
             * @param myQuery string containing the query.
             * @return the result.
             * @throws omero::ServerError
             */
            idempotent IObjectList findAllByQuery(string myQuery)
                throws omero::ServerError;

            /*
             * Run the query passed as a string in the iQuery interface.
             * The method expects to return only one result from the query, if more than
             * one result is to be returned the method will throw an exception.
             * @param myQuery string containing the query.
             * @return the result.
             * @throws omero::ServerError
             */
            idempotent omero::model::IObject findByQuery(string myQuery)
                throws omero::ServerError;

            /*
             * Get the raw plane for the pixels pixelsId, this returns a 2d array
             * representing the plane, it returns doubles but will not lose data.
             * @param pixelsId id of the pixels to retrieve.
             * @param c the channel of the pixels to retrieve.
             * @param t the time point to retrieve.
             * @param z the z section to retrieve.
             * @return The raw plane in 2-d array of doubles.
             * @throws omero::ServerError
             */
            idempotent DoubleArrayArray getPlane(long pixelsId, int z, int c, int t)
                throws omero::ServerError;

            /*
             * Get the pixels information for an image, this method will also
             * attach the logical channels, channels, and other metadata in the pixels.
             * @param pixelsId image id relating to the pixels.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent omero::model::Pixels getPixels(long pixelsId)
                throws omero::ServerError;

            /*
             * Copy the pixels to a new pixels, this is only the data object
             * and does not create a pixels object in the RawPixelsStore,
             * To load data into the plane the {@link #uploadPlane(long, int, int, int, DoubleArrayArray)}
             * to add data to the pixels.
             * @param pixelsID pixels id to copy.
             * @param x width of plane.
             * @param y height of plane.
             * @param t num timepoints
             * @param z num zsections.
             * @param channelList the list of channels to copy, this is the channel index.
             * @param methodology user supplied text, describing the methods that
             * created the pixels.
             * @return new id.
             * @throws omero::ServerError
             */
            long copyPixelsXYTZ(long pixelsID, int x, int y, int t, int z, IntegerList channelList, string methodology)
                throws omero::ServerError;

            /*
             * Copy the pixels to a new pixels, this is only the data object
             * and does not create a pixels object in the RawPixelsStore,
             * To load data into the plane the {@link #uploadPlane(long, DoubleArrayArray)}
             * to add data to the pixels.
             * @param pixelsID pixels id to copy.
             * @param channelList the list of channels to copy, this is the channel index.
             * @param methodology user supplied text, describing the methods that
             * created the pixels.
             * @return new id.
             * @throws omero::ServerError
             */
            long copyPixels(long pixelsID, IntegerList channelList, string methodology)
                throws omero::ServerError;

            /*
             * Copy the image and it's attached pixels and
             * metadata to a new Image and return the id of the new image. The method
             * will not copy annotations or attachments.
             * @param imageId image id to copy.
             * @param x width of plane.
             * @param y height of plane.
             * @param t The number of time-points
             * @param z The number of zSections.
             * @param channelList the list of channels to copy, [0-(sizeC-1)].
             * @param imageName The new imageName.
             * @return new id.
             * @throws omero::ServerError
             */
            long copyImage(long imageId, int x, int y, int t, int z, IntegerList channelList, string imageName)
                throws omero::ServerError;

            /*
             * Upload the plane to the server, on pixels id with channel and the
             * time, + z section. the data is the client 2d data values. This will
             * be converted to the raw server bytes.
             * @param pixelsId pixels id to upload to .
             * @param z z section.
             * @param c channel.
             * @param t time point.
             * @param data plane data.
             * @throws omero::ServerError
             */
            idempotent void uploadPlane(long pixelsId, int z, int c, int t, DoubleArrayArray data)
                throws omero::ServerError;

            /*
             * Update the pixels object on the server, updating appropriate tables in the
             * database and returning a new copy of the pixels.
             * @param object see above.
             * @return the new updated pixels.
             * @throws omero::ServerError
             */
            idempotent omero::model::Pixels updatePixels(omero::model::Pixels pixels)
                throws omero::ServerError;

            /*
             * Get a list of all the possible pixelsTypes in the server.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent PixelsTypeList getPixelTypes()
                throws omero::ServerError;

            /*
             * Get the pixelsType for type of name type.
             * @param type see above.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent omero::model::PixelsType getPixelType(string type)
                throws omero::ServerError;

            /*
             * Get the scripts from the iScript Service.
             * @return All the available scripts in a map by id and name.
             * @throws omero::ServerError
             */
            idempotent LongStringMap getScripts()
                throws omero::ServerError;

            /*
             * Get the id of the script with name
             * @param name name of the script.
             * @return the id of the script.
             * @throws omero::ServerError
             */
            idempotent long getScriptID(string name)
                throws omero::ServerError;

            /*
             * Upload the script to the server.
             * @param script script to upload
             * @return id of the new script.
             * @throws omero::ServerError
             */
            long uploadScript(string script)
                throws omero::ServerError;

            /*
             * Get the script with id, this returns the actual script as a string.
             * @param id id of the script to retrieve.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent string getScript(long id)
                throws omero::ServerError;

            /*
             * Get the parameters the script takes, this is a map of the parameter name and type.
             * @param id id of the script.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent StringRTypeMap getParams(long id)
                throws omero::ServerError;

            /*
             * Run the script and get the results returned as a name , value map.
             * @param id id of the script to run.
             * @param map the map of parameters, values for inputs.
             * @return see above.
             * @throws omero::ServerError
             */
            StringRTypeMap runScript(long id, StringRTypeMap map)
                throws omero::ServerError;

            /*
             * Delete the script with id from the server.
             * @param id id of the script to delete.
             * @throws omero::ServerError
             */
            void deleteScript(long id)
                throws omero::ServerError;

            /*
             * Get the zSection stack from the pixels at timepoint t
             * @param pixelId The pixelsId from the imageStack.
             * @param c The channel.
             * @param t The time-point.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent DoubleArrayArrayArray getPlaneStack(long pixelId, int c, int t)
                throws omero::ServerError;

            /*
             * Render the pixels for the zSection z and timePoint t.
             * @param pixelsId pixels id of the plane to render
             * @param z z section to render
             * @param t timepoint to render
             * @return The image as a buffered image.
             * @throws omero::ServerError
             */
            idempotent BufferedImage getRenderedImage(long pixelsId, int z, int t)
		throws omero::ServerError;

            /*
             * Render the pixels for the zSection z and timePoint t.
             * @param pixelsId pixels id of the plane to render
             * @param z z section to render
             * @param t timepoint to render
             * @return The image as a 3d array where it represents the image as
             * [x][y][channel]
             * @throws omero::ServerError
             */
            idempotent IntegerArrayArrayArray getRenderedImageMatrix(long pixelsId, int z, int t)
		throws omero::ServerError;

            /*
             * Render the pixels for the zSection z and timePoint t.
             * @param pixelsId pixels id of the plane to render
             * @param z z section to render
             * @param t timepoint to render
             * @return The pixels are returned as 4 bytes representing the r,g,b,a of
             * image.
             * @throws omero::ServerError
             */
            idempotent IntegerArray renderAsPackedInt(long pixelsId, int z, int t)
		throws omero::ServerError;

            /*
             * Set the active channels to be on or off in the rendering engine for
             * the pixels.
             * @param pixelsId the pixels id.
             * @param w the channel
             * @param active set active?
             * @throws omero::ServerError
             */
            void setActive(long pixelsId, int w, bool active)
		throws omero::ServerError;

            /*
             * Is the channel active, turned on in the rendering engine.
             * @param pixelsId the pixels id.
             * @param w channel
             * @return true if the channel active.
             * @throws omero::ServerError
             */
            idempotent bool isActive(long pixelsId, int w)
		throws omero::ServerError;

            /*
             * Get the default zSection of the image, this is the zSection the image
             * should open on when an image viewer is loaded.
             * @param pixelsId the pixelsId of the image.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent int getDefaultZ(long pixelsId)
		throws omero::ServerError;

            /*
             * Get the default time-point of the image, this is the time-point the image
             * should open on when an image viewer is loaded.
             * @param pixelsId the pixelsId of the image.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent int getDefaultT(long pixelsId)
		throws omero::ServerError;

            /*
             * Set the default zSection of the image, this is the zSection the image
             * should open on when an image viewer is loaded.
             * @param pixelsId the pixelsId of the image.
             * @param z see above.
             * @throws omero::ServerError
             */
            void setDefaultZ(long pixelsId, int z)
		throws omero::ServerError;

            /*
             * Set the default timepoint of the image, this is the timepoint the image
             * should open on when an image viewer is loaded.
             * @param pixelsId the pixelsId of the image.
             * @param t see above.
             * @throws omero::ServerError
             */
            void setDefaultT(long pixelsId, int t)
		throws omero::ServerError;

            /*
             * Set the channel Minimum, Maximum values, that map from image space to
             * rendered space (3 channel, 8 bit, screen).
             * @param pixelsId the pixelsId of the image the mapping applied to.
             * @param w channel of the pixels.
             * @param start The minimum value to map from.
             * @param end The maximum value to map to.
             * @throws omero::ServerError
             */
            void setChannelWindow(long pixelsId, int w, double start, double end)
		throws omero::ServerError;

            /*
             * Get the channel Minimum value, that maps from image space to
             * rendered space.
             * @param pixelsId the pixelsId of the image the mapping applied to.
             * @param w channel of the pixels.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent double getChannelWindowStart(long pixelsId, int w)
		throws omero::ServerError;

            /*
             * Get the channel Maximum value, that maps from image space to
             * rendered space.
             * @param pixelsId the pixelsId of the image the mapping applied to.
             * @param w channel of the pixels.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent double getChannelWindowEnd(long pixelsId, int w)
		throws omero::ServerError;

            /*
             * Set the rendering definition of the rendering engine from the default
             * to the one supplied. This allows for more than one rendering definition-
             * mapping per pixels.
             * @param pixelsId for pixelsId
             * @param renderingDefId see above.
             * @throws omero::ServerError
             */
            void setRenderingDefId(long pixelsId, long renderingDefId)
		throws omero::ServerError;

            /*
             * Get the thumbnail of the image.
             * @param pixelsId for pixelsId
             * @param sizeX size of thumbnail.
             * @param sizeY size of thumbnail.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent ByteArray getThumbnail(long pixelsId, omero::RInt sizeX, omero::RInt sizeY)
                throws omero::ServerError;

            /*
             * Get a set of thumbnails, of size X, Y from the list of pixelId's supplied
             * in the list.
             * @param sizeX size of thumbnail.
             * @param sizeY size of thumbnail.
             * @param pixelsIds list of ids.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent LongByteArrayMap getThumbnailSet(omero::RInt sizeX, omero::RInt sizeY, LongList pixelsIds)
		throws omero::ServerError;

            /*
             * Get a set of thumbnails from the pixelsId's in the list,
             * maintaining aspect ratio.
             * @param size size of thumbnail.
             * @param pixelsIds list of ids.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent LongByteArrayMap getThumbnailBylongestSideSet(omero::RInt size, LongList pixelsIds)
                throws omero::ServerError;

            /*
             * Get the thumbnail of the image, maintain aspect ratio.
             * @param pixelsId for pixelsId
             * @param size size of thumbnail.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent ByteArray getThumbnailBylongestSide(long pixelsId, omero::RInt size)
                throws omero::ServerError;

            /*
             * Attach an image to a dataset.
             * @param dataset see above.
             * @param image see above.
             * @throws omero::ServerError
             *
             */
            void attachImageToDataset(omero::model::Dataset dataset, omero::model::Image image)
                throws omero::ServerError;

            /*
             * Create a new Image of X,Y, and zSections+time-points. The channelList is
             * the emission wavelength of the channel and the pixelsType.
             * @param sizeX width of plane.
             * @param sizeY height of plane.
             * @param sizeZ num zSections.
             * @param sizeT num time-points
             * @param channelList the list of channels to copy.
             * @param pixelsType the type of pixels in the image.
             * @param name the image name.
             * @param description the description of the image.
             * @return new id.
             * @throws omero::ServerError
             */
            long createImage(int sizeX, int sizeY, int sizeZ, int sizeT,
                             IntegerList channelList, omero::model::PixelsType pixelsType, string name,
                             string description)
		throws omero::ServerError;
            /*
             * Get the images from as dataset.
             * @param dataset see above.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent ImageList getImagesFromDataset(omero::model::Dataset dataset)
                throws omero::ServerError;

            /*
             * Get the plane from the image with imageId.
             * @param imageId see above.
             * @param z zSection of the plane.
             * @param c channel of the plane.
             * @param t timepoint of the plane.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent DoubleArrayArray getPlaneFromImage(long imageId, int z, int c, int t)
		throws omero::ServerError;

            /*
             * This is a helper method and makes no calls to the server. It
             * gets a list of all the dataset in a project if the project has already
             * had the datasets attached, via getLeaves in {@link #getProjects(List, bool)}
             * or fetched via HQL in {@link #findAllByQuery(string)}, {@link #findByQuery(string)}
             * @param project see above.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent DatasetList getDatasetsFromProject(omero::model::Project project)
                throws omero::ServerError;

            /*
             * This is a helper method and makes no calls to the server. It
             * gets a list of all the pixels in a dataset if the dataset has already
             * had the pixels attached, via getLeaves in {@link #getProjects(List, bool)}
             * {@link #getDatasets(List, bool)} or fetched via HQL in
             * {@link #findAllByQuery(string)}, {@link #findByQuery(string)}
             * @param dataset see above.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent PixelsList getPixelsFromDataset(omero::model::Dataset dataset)
                throws omero::ServerError;

            /*
             * This is a helper method and makes no calls to the server. It
             * gets a list of all the pixels in a project if the project has already
             * had the pixels attached, via getLeaves in {@link #getProjects(List, bool)}
             * or fetched via HQL in {@link #findAllByQuery(string)},
             * {@link #findByQuery(string)}
             * @param project see above.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent PixelsList getPixelsFromProject(omero::model::Project project)
                throws omero::ServerError;

            /*
             * This is a helper methods, which makes no calls to the server. It get all
             * the pixels attached to a list of images. It requires that the pixels are
             * already attached via  {@link #getProjects(List, bool)}
             * {@link #getDatasets(List, bool)} or fetched via HQL in
             * {@link #findAllByQuery(string)}, {@link #findByQuery(string)}
             * Get the pixels from the images in the list.
             * @param images see above.
             * @return map of the pixels-->imageId.
             */
            idempotent LongPixelsMap getPixelsImageMap(ImageList images)
                throws omero::ServerError;

            /*
             * This is a helper methods, which makes no calls to the server. It get all
             * the pixels attached to a list of images. It requires that the pixels are
             * already attached via  {@link #getProjects(List, bool)}
             * {@link #getDatasets(List, bool)} or fetched via HQL in
             * {@link #findAllByQuery(string)}, {@link #findByQuery(string)}
             * Get the pixels from the images in the list.
             * @param images see above.
             * @return list of the pixels.
             */
            idempotent PixelsList getPixelsFromImageList(ImageList images)
                throws omero::ServerError;

            /*
             * Get the images from the dataset with name, this can use wild cards.
             * @param datasetId see above.
             * @param imageName see above.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent ImageList getImageFromDatasetByName(long datasetId, string imageName)
                throws omero::ServerError;

            /*
             * Get the list of images with name containing imageName.
             * @param imageName see above.
             * @return see above.
             * @throws omero::ServerError
             */
            idempotent ImageList getImageByName(string imageName)
                throws omero::ServerError;

            /*
             * Save the object to the db .
             * @param obj see above.
             * @throws omero::ServerError
             */
            void saveObject(omero::model::IObject obj)
                throws omero::ServerError;

            /*
             * Save and return the Object.
             * @param obj see above.
             * @return see above.
             * @throws omero::ServerError
             */
            omero::model::IObject saveAndReturnObject(omero::model::IObject obj)
                throws omero::ServerError;

            /*
             * Save the array.
             * @param graph see above.
             * @throws omero::ServerError
             */
            void saveArray(IObjectList graph)
                throws omero::ServerError;

            /*
             * Save and return the array.
             * @param <T> The Type to return.
             * @param graph the object
             * @return see above.
             * @throws omero::ServerError
             */
            IObjectList saveAndReturnArray(IObjectList graph)
                 throws omero::ServerError;
            /*
             * Delete the object.
             * @param row the object.(commonly a row in db)
             * @throws omero::ServerError
             */
            void deleteObject(omero::model::IObject row)
                throws omero::ServerError;

            /*
             * Get the username.
             * @return see above.
             */
            idempotent string getUsername()
                throws omero::ServerError;

            /*
             * Keep service alive.
             * @throws omero::ServerError
             */
            idempotent void keepAlive()
                throws omero::ServerError;

        };

    };
};

#endif